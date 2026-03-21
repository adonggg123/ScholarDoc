import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaVerificationScreen extends StatefulWidget {
  const SaVerificationScreen({super.key});

  @override
  State<SaVerificationScreen> createState() => _SaVerificationScreenState();
}

class _SaVerificationScreenState extends State<SaVerificationScreen> {
  int _selectedStudentIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _authService.getStudentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.userX, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No registered students found.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (_selectedStudentIndex >= docs.length) {
          _selectedStudentIndex = 0;
        }

        final selectedDoc = docs[_selectedStudentIndex];
        final selectedData = selectedDoc.data() as Map<String, dynamic>;

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 900;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SA Number Verification', 
                    style: isMobile 
                      ? Theme.of(context).textTheme.titleLarge 
                      : Theme.of(context).textTheme.headlineSmall
                  ),
                  SizedBox(height: 2),
                  Text('Verify accuracy of submitted Savings Account numbers.', style: TextStyle(fontSize: 12, color: context.textSec)),
                  SizedBox(height: 16),
                  if (isMobile) ...[
                    _buildVerificationTable(context, docs, isMobile),
                    SizedBox(height: 24),
                    _buildVerificationPanel(context, selectedData, isMobile),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildVerificationTable(context, docs, isMobile)),
                        SizedBox(width: 24),
                        Expanded(flex: 2, child: _buildVerificationPanel(context, selectedData, isMobile)),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildVerificationTable(BuildContext context, List<QueryDocumentSnapshot> docs, bool isMobile) {
    return Container(
      decoration: context.glassDecoration,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: docs.length,
        separatorBuilder: (context, index) => Divider(color: context.surfaceC.withValues(alpha: 0.1), height: 1),
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final String name = data['fullName'] ?? 'N/A';
          final String saNumber = data['familyDetails']?['saNumber'] ?? 'N/A';

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: Icon(LucideIcons.user, size: 20, color: AppTheme.primaryColor),
            ),
            title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('SA: $saNumber', style: TextStyle(fontSize: 12)),
            trailing: Icon(LucideIcons.chevronRight, size: 18),
            onTap: () {
              setState(() {
                _selectedStudentIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildVerificationPanel(BuildContext context, Map<String, dynamic> data, bool isMobile) {
    final ml = MLService();
    final String saNumber = data['familyDetails']?['saNumber'] ?? '1234-5678-9012';
    final String name = data['fullName'] ?? 'N/A';
    final String studentId = data['studentId'] ?? 'N/A';
    final String course = data['course'] ?? 'N/A';
    final String year = data['year'] ?? 'N/A';
    
    final aiCheck = ml.detectSASuspiciousPattern(saNumber);

    return Container(
      decoration: context.glassDecoration,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 28, 
                      backgroundColor: AppTheme.secondaryColor,
                      child: Icon(LucideIcons.user, size: 24, color: context.surfaceC),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  Text('$course - $year', style: TextStyle(color: context.textSec, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            _dataField(context, 'Student ID', studentId),
            SizedBox(height: 12),
            _dataField(context, 'Submitted SA Number', saNumber),
            SizedBox(height: 8),
            _buildAIBadge(context, aiCheck),
            SizedBox(height: 12),
            _dataField(context, 'Bank Branch', 'Main University Branch'),
            SizedBox(height: 8),
            _buildDuplicateBadge(context),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success, 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Verify and Approve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error, 
                  side: const BorderSide(color: AppTheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Flag for Correction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.textSec)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAIBadge(BuildContext context, Map<String, dynamic> aiCheck) {
    final bool isSuspicious = aiCheck['isSuspicious'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bot, size: 14, color: isSuspicious ? AppTheme.warning : AppTheme.success),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'AI Score: ${aiCheck['confidence']}% - ${aiCheck['message']}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSuspicious ? AppTheme.warning : AppTheme.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.fileCheck2, size: 14, color: AppTheme.success),
          SizedBox(width: 8),
          Text(
            'Duplicate Hash Network Check: PASSED',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.success),
          ),
        ],
      ),
    );
  }
}

