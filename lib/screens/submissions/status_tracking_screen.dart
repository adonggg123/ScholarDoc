import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';

import '../../services/scholarship_service.dart';

class StatusTrackingScreen extends StatefulWidget {
  const StatusTrackingScreen({super.key});

  @override
  State<StatusTrackingScreen> createState() => _StatusTrackingScreenState();
}

class _StatusTrackingScreenState extends State<StatusTrackingScreen> {
  final AuthService _authService = AuthService();
  final ScholarshipService _scholarshipService = ScholarshipService();
  late Stream<DocumentSnapshot> _studentStream;
  
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
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.filter),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _studentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
          final String scholarshipName = data['scholarshipName'] ?? 'No Scholarship Assigned';

          Color statusColor = AppTheme.warning;
          if (status == 'Approved') statusColor = AppTheme.success;
          if (status == 'Rejected') statusColor = AppTheme.error;

          return FutureBuilder<Scholarship?>(
            future: scholarshipId.isNotEmpty ? _scholarshipService.getScholarshipById(scholarshipId) : Future.value(null),
            builder: (context, scholarshipSnapshot) {
              final List<String> requirements = scholarshipSnapshot.data?.requiredDocuments ?? ['General Enrollment Form', 'ID Card', 'Signature'];
              
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildStatusHeader(context, scholarshipName, status, statusColor, remarks, submittedDate),
                  const SizedBox(height: 32),
                  Text('Document Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  ...requirements.map((doc) => _buildRequirementItem(context, doc, status == 'Approved')).toList(),
                  if (data['requiresResubmission'] == true) ...[
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.uploadCloud),
                      label: const Text('Resubmit Documents'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildStatusHeader(BuildContext context, String name, String status, Color color, String? remarks, String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.crispDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Submitted on $date', style: TextStyle(color: context.textSec, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (remarks != null && remarks.isNotEmpty) ...[
             const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(LucideIcons.messageCircle, size: 14, color: color),
                       const SizedBox(width: 8),
                       Text('Official Feedback', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(remarks, style: const TextStyle(fontSize: 13)),
                 ],
               ),
             ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String title, bool isVerified) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceC.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.surfaceC.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(isVerified ? LucideIcons.checkCircle2 : LucideIcons.circle, 
            color: isVerified ? AppTheme.success : context.textSec, 
            size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: isVerified ? FontWeight.w600 : FontWeight.normal))),
          if (!isVerified) const Icon(LucideIcons.upload, size: 16, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}
