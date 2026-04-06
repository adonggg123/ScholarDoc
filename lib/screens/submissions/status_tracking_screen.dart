import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';

import '../../services/scholarship_service.dart';
import 'upload_workflow_screen.dart';

class StatusTrackingScreen extends StatefulWidget {
  const StatusTrackingScreen({super.key});

  @override
  State<StatusTrackingScreen> createState() => _StatusTrackingScreenState();
}

class _StatusTrackingScreenState extends State<StatusTrackingScreen> {
  final AuthService _authService = AuthService();
  final ScholarshipService _scholarshipService = ScholarshipService();
  Stream<DocumentSnapshot>? _studentStream;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _studentStream = _authService.getStudentStream(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submissions'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.filter)),
        ],
      ),
      body: _studentStream == null 
        ? const Center(child: Text('Connecting to service...'))
        : StreamBuilder<DocumentSnapshot>(
            stream: _studentStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your submission status...'),
                    ],
                  ),
                );
              }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading status data'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No submission data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String status = data['status'] ?? 'Pending';
          var submittedDate = 'N/A';
          if (data['createdAt'] != null) {
            final Timestamp ts = data['createdAt'];
            submittedDate = DateFormat('MMM d, yyyy').format(ts.toDate());
          }
          final String? remarks = data['adminRemarks'];
          final String scholarshipId = data['scholarshipId'] ?? '';
          final String scholarshipName =
              data['scholarshipName'] ?? 'No Scholarship Assigned';

          Color statusColor = AppTheme.warning;
          if (status == 'Approved') statusColor = AppTheme.success;
          if (status == 'Rejected') statusColor = AppTheme.error;

          return FutureBuilder<Scholarship?>(
            future: scholarshipId.isNotEmpty
                ? _scholarshipService.getScholarshipById(scholarshipId)
                : Future.value(null),
            builder: (context, scholarshipSnapshot) {
              final List<String> requirements =
                  scholarshipSnapshot.data?.requiredDocuments ??
                  ['General Enrollment Form', 'ID Card', 'Signature'];

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildStatusHeader(
                    context,
                    scholarshipName,
                    status,
                    statusColor,
                    remarks,
                    submittedDate,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Document Checkpoint',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ...requirements
                      .map(
                        (doc) => _buildRequirementItem(
                          context,
                          doc,
                          status == 'Approved',
                        ),
                      )
                      .toList(),
                  if (data['requiresResubmission'] == true) ...[
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [AppTheme.warning, Color(0xFFF59E0B)],
                        ),
                        boxShadow: AppTheme.premiumShadow,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const UploadWorkflowScreen()),
                          );
                        },
                        icon: const Icon(LucideIcons.uploadCloud, color: Colors.white),
                        label: const Text('Action Required: Resubmit Docs', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
            },
          ),
    );
  }

  Widget _buildStatusHeader(
    BuildContext context,
    String name,
    String status,
    Color color,
    String? remarks,
    String date,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.surfaceC,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.premiumShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == 'Approved' ? LucideIcons.checkCircle2 : (status == 'Rejected' ? LucideIcons.xCircle : LucideIcons.clock),
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 16, color: context.textSec),
                    const SizedBox(width: 8),
                    Text(
                      'Submitted on $date',
                      style: TextStyle(color: context.textSec, fontSize: 13),
                    ),
                  ],
                ),
                if (remarks != null && remarks.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(LucideIcons.messageCircle, size: 18, color: color),
                      const SizedBox(width: 10),
                      Text(
                        'Official Remarks',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    remarks,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textPri,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String title,
    bool isVerified,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isVerified
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadWorkflowScreen()),
                );
              },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: context.surfaceC,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isVerified ? AppTheme.success.withValues(alpha: 0.2) : context.crispBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified ? AppTheme.success.withValues(alpha: 0.1) : context.bgC,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVerified ? LucideIcons.check : LucideIcons.fileText,
                  color: isVerified ? AppTheme.success : context.textSec,
                  size: 20,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isVerified ? FontWeight.bold : FontWeight.w500,
                        color: isVerified ? AppTheme.success : context.textPri,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isVerified ? 'Verified' : 'Action required',
                      style: TextStyle(
                        fontSize: 11,
                        color: isVerified ? AppTheme.success.withValues(alpha: 0.7) : context.textSec,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isVerified)
                const Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
