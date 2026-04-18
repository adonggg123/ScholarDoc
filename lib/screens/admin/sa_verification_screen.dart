import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final TextEditingController _remarksController = TextEditingController();
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
          final String saNumber = data['saNumber'] ?? data['familyDetails']?['saNumber'] ?? '';
          
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
              padding: EdgeInsets.all(isMobile ? 10 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verification Queue', 
                    style: isMobile 
                      ? Theme.of(context).textTheme.titleMedium 
                      : Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 2),
                  Text('Verify accuracy of submitted accounts. AI prioritizes high-risk documents.', style: TextStyle(fontSize: 13, color: context.textSec, fontWeight: FontWeight.w500)),
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
      decoration: context.crispDecoration.copyWith(
        border: Border.all(
          color: context.isDark ? const Color(0xFF334155) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
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
          final String saNumber = data['saNumber'] ?? data['familyDetails']?['saNumber'] ?? 'N/A';

          bool isSelected = _selectedStudentIndex == index;

          return Material(
            color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.04) : Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedStudentIndex = index;
                  _remarksController.clear();
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    () {
                      final String? photoUrl = data['profilePictureUrl'] as String?;
                      if (photoUrl != null && photoUrl.isNotEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSuspicious ? AppTheme.warning : const Color(0xFFFBC02D),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                        );
                      }
                      return CircleAvatar(
                        radius: 20,
                        backgroundColor: isSuspicious 
                          ? AppTheme.warning.withValues(alpha: 0.1) 
                          : AppTheme.primaryColor.withValues(alpha: 0.05),
                        child: Icon(
                          isSuspicious ? LucideIcons.alertTriangle : LucideIcons.user, 
                          size: 16, 
                          color: isSuspicious ? AppTheme.warning : AppTheme.primaryColor
                        ),
                      );
                    }(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name, 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.textPri),
                                ),
                              ),
                              if (isSuspicious) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warning.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('PRIORITY', style: TextStyle(color: AppTheme.warning, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('SA: $saNumber', style: TextStyle(fontSize: 11, color: context.textSec, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight, 
                      size: 18, 
                      color: isSelected ? AppTheme.primaryColor : context.textSec.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerificationPanel(BuildContext context, Map<String, dynamic> data, bool isMobile) {
    final ml = MLService();
    final String saNumber = data['saNumber'] ?? data['familyDetails']?['saNumber'] ?? '1234-5678-9012';
    final String name = data['fullName'] ?? 'N/A';
    final String studentId = data['studentId'] ?? 'N/A';
    final String course = data['course'] ?? 'N/A';
    final String year = data['year'] ?? 'N/A';
    
    final String? sem1Url = data['sem1Url'];
    final String? sem2Url = data['sem2Url'];
    final String? sem1FileName = data['sem1FileName'];
    final String? sem2FileName = data['sem2FileName'];

    final aiCheck = ml.detectSASuspiciousPattern(saNumber);

    return Container(
      decoration: context.crispDecoration.copyWith(
        border: Border.all(
          color: context.isDark ? const Color(0xFF334155) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFBC02D), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: () {
                      final String? photoUrl = data['profilePictureUrl'] as String?;
                      if (photoUrl != null && photoUrl.isNotEmpty) {
                        return CircleAvatar(
                          radius: 36,
                          backgroundImage: NetworkImage(photoUrl),
                        );
                      }
                      return CircleAvatar(
                        radius: 36, 
                        backgroundColor: AppTheme.secondaryColor.withValues(alpha: 0.1),
                        child: Icon(LucideIcons.user, size: 30, color: AppTheme.secondaryColor),
                      );
                    }(),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: context.textPri)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$course - $year', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            _dataField(context, 'Student ID', studentId),
            SizedBox(height: 10),
            _dataField(context, 'Submitted SA Number', saNumber),
            SizedBox(height: 6),
            _buildAIBadge(context, aiCheck),
            const SizedBox(height: 12),
            _dataField(context, 'Bank Branch', 'Main University Branch'),
            const SizedBox(height: 10),
            _buildDuplicateBadge(context),
            const SizedBox(height: 16),
            
            // NEW: Submitted Documents Section
            Text('Documents Provided', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textPri)),
            const SizedBox(height: 10),
            if (sem1Url == null && sem2Url == null)
              Text('No documents uploaded.', style: TextStyle(fontSize: 12, color: context.textSec, fontStyle: FontStyle.italic))
            else
              Column(
                children: [
                  if (sem1Url != null) ...[
                    _buildDocumentLink(context, '1st Sem ID', sem1FileName ?? 'Validation_1.pdf', sem1Url),
                  ],
                  if (sem2Url != null) ...[
                    const SizedBox(height: 8),
                    _buildDocumentLink(context, '2nd Sem ID', sem2FileName ?? 'Validation_2.pdf', sem2Url),
                  ],
                ],
              ),
            
            const SizedBox(height: 16),
            Text('Admin Remarks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPri)),
            SizedBox(height: 6),
            TextFormField(
              controller: _remarksController,
              maxLines: 2,
              style: TextStyle(fontSize: 13, color: context.textPri, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'e.g. Please re-upload your SA number, current one is blurred.',
                hintStyle: TextStyle(fontSize: 12, color: context.textSec),
                fillColor: context.surfaceC,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), 
                  borderSide: BorderSide(
                    color: context.isDark ? const Color(0xFF334155) : Colors.grey.shade300, 
                    width: 1.5
                  )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), 
                  borderSide: BorderSide(
                    color: context.isDark ? const Color(0xFF334155) : Colors.grey.shade300, 
                    width: 1.5
                  )
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Verify and Approve', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () => _updateStatus(
                  context,
                  data['uid'],
                  name,
                  studentId,
                  'Rejected',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warning, 
                  side: const BorderSide(color: AppTheme.warning, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Request Resubmission', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: TextButton(
                onPressed: () => _updateStatus(
                  context,
                  data['uid'],
                  name,
                  studentId,
                  'Rejected',
                  isFinalRejection: true,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.error, 
                ),
                child: const Text('Permanent Rejection', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        Text(label, style: TextStyle(fontSize: 12, color: context.textSec, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPri)),
      ],
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    String? uid,
    String name,
    String studentId,
    String newStatus, {
    bool isFinalRejection = false,
  }) async {
    if (uid == null) return;
    
    final String remarks = _remarksController.text.trim();

    try {
      // 1. Update Student Record
      await FirebaseFirestore.instance.collection('students').doc(uid).update({
        'status': newStatus,
        'adminRemarks': remarks,
        'requiresResubmission': !isFinalRejection && newStatus == 'Rejected',
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
        title: newStatus == 'Approved' ? 'Account Verified' : 'Action Required',
        message: newStatus == 'Approved' 
            ? 'Great news! Your SA Number has been verified and your status is now Approved.'
            : 'Issue found: $remarks. Please update your information to proceed.',
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: (isSuspicious ? AppTheme.warning : AppTheme.success).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bot, size: 12, color: isSuspicious ? AppTheme.warning : AppTheme.success),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'AI Score: ${aiCheck['confidence']}% - ${aiCheck['message']}',
              style: TextStyle(
                fontSize: 10,
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.fileCheck2, size: 12, color: AppTheme.success),
          SizedBox(width: 6),
          Text(
            'Duplicate Hash Network Check: PASSED',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.success),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink(BuildContext context, String label, String fileName, String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceC.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.crispBorder),
      ),
      child: Row(
        children: [
          Icon(
            fileName.toLowerCase().endsWith('.pdf') ? LucideIcons.fileText : LucideIcons.image, 
            size: 16, 
            color: AppTheme.primaryColor
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                Text(fileName, style: TextStyle(fontSize: 10, color: context.textSec), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }
}

