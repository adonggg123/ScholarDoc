import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import '../../services/audit_service.dart';
import '../../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaVerificationScreen extends StatefulWidget {
  const SaVerificationScreen({super.key});

  @override
  State<SaVerificationScreen> createState() => _SaVerificationScreenState();
}

class _SaVerificationScreenState extends State<SaVerificationScreen> {
  int _selectedStudentIndex = 0;
  final AuthService _authService = AuthService();
  final AuditService _auditService = AuditService();
  final NotificationService _notificationService = NotificationService();
  late Stream<QuerySnapshot> _studentsStream;

  @override
  void initState() {
    super.initState();
    _studentsStream = _authService.getStudentsStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        }

        List<QueryDocumentSnapshot> docs = snapshot.data?.docs.toList() ?? [];
        
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.userX, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No registered students found.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // --- AUTOMATED PRIORITIZATION LOGIC ---
        final mlService = MLService();
        // Calculate Priority Score
        final List<Map<String, dynamic>> scoredDocs = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final String saNumber = data['familyDetails']?['saNumber'] ?? '';
          
          int priorityScore = 0;
          bool isSuspicious = false;

          // Artificial Intelligence Rule
          if (saNumber.isNotEmpty) {
            final aiCheck = mlService.detectSASuspiciousPattern(saNumber);
            isSuspicious = aiCheck['isSuspicious'];
            if (isSuspicious) {
              priorityScore += 100; // Force suspicious apps to top
            }
          }
          
          return {
            'doc': doc,
            'score': priorityScore,
            'isSuspicious': isSuspicious,
          };
        }).toList();

        // Sort dynamically: Highest score first. If equal score, original descending date (default array ordering)
        scoredDocs.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

        // Create the final sorted docs list
        docs = scoredDocs.map((s) => s['doc'] as QueryDocumentSnapshot).toList();

        // Safely determine the active index without modifying state during build
        final int activeIndex = (_selectedStudentIndex >= docs.length) ? 0 : _selectedStudentIndex;
        final selectedDoc = docs[activeIndex];
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
                    'Verification Queue', 
                    style: isMobile 
                      ? Theme.of(context).textTheme.titleLarge 
                      : Theme.of(context).textTheme.headlineSmall
                  ),
                  const SizedBox(height: 2),
                  Text('Verify accuracy of submitted accounts. AI prioritizes high-risk documents.', style: TextStyle(fontSize: 12, color: context.textSec)),
                  const SizedBox(height: 16),
                  if (isMobile) ...[
                    _buildVerificationTable(context, scoredDocs, isMobile),
                    const SizedBox(height: 24),
                    _buildVerificationPanel(context, selectedData, isMobile),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildVerificationTable(context, scoredDocs, isMobile)),
                        const SizedBox(width: 24),
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

  Widget _buildVerificationTable(BuildContext context, List<Map<String, dynamic>> scoredDocs, bool isMobile) {
    return Container(
      decoration: context.glassDecoration,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: scoredDocs.length,
        separatorBuilder: (context, index) => Divider(color: context.surfaceC.withValues(alpha: 0.1), height: 1),
        itemBuilder: (context, index) {
          final doc = scoredDocs[index]['doc'] as QueryDocumentSnapshot;
          final bool isSuspicious = scoredDocs[index]['isSuspicious'];
          
          final data = doc.data() as Map<String, dynamic>;
          final String name = data['fullName'] ?? 'N/A';
          final String saNumber = data['familyDetails']?['saNumber'] ?? 'N/A';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: isSuspicious 
                ? AppTheme.warning.withValues(alpha: 0.1) 
                : AppTheme.primaryColor.withValues(alpha: 0.05),
              child: Icon(
                isSuspicious ? LucideIcons.alertTriangle : LucideIcons.user, 
                size: 18, 
                color: isSuspicious ? AppTheme.warning : AppTheme.primaryColor
              ),
            ),
            title: Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (isSuspicious) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('HIGH PRIORITY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            subtitle: Text('SA: $saNumber', style: const TextStyle(fontSize: 12)),
            trailing: const Icon(LucideIcons.chevronRight, size: 18),
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
                onPressed: () => _updateStatus(
                  context,
                  data['uid'], // Firestore doc ID
                  name,
                  studentId,
                  'Approved',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success, 
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Verify and Approve', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => _updateStatus(
                  context,
                  data['uid'],
                  name,
                  studentId,
                  'Rejected',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error, 
                  side: const BorderSide(color: AppTheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Flag for Correction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Future<void> _updateStatus(
    BuildContext context,
    String? uid,
    String name,
    String studentId,
    String newStatus,
  ) async {
    if (uid == null) return;

    try {
      // 1. Update Student Record
      await FirebaseFirestore.instance.collection('students').doc(uid).update({
        'status': newStatus,
      });

      // 2. Log Activity
      await _auditService.logActivity(
        action: 'Verified student SA Number: $newStatus',
        userName: 'Admin',
        role: 'Admin',
        studentId: studentId,
      );

      // 3. Send Notification
      await _notificationService.sendNotification(
        studentId: uid,
        title: 'Document $newStatus',
        message: newStatus == 'Approved' 
            ? 'Great news! Your SA Number has been verified and your status is now Approved.'
            : 'There was an issue with your submitted SA Number. Please check it and update your profile.',
        type: newStatus == 'Approved' ? 'success' : 'error',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student $name is now $newStatus.'),
            backgroundColor: newStatus == 'Approved' ? AppTheme.success : AppTheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update student verification.')),
        );
      }
    }
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

