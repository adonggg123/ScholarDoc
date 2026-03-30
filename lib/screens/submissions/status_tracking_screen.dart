import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';

class StatusTrackingScreen extends StatefulWidget {
  const StatusTrackingScreen({super.key});

  @override
  State<StatusTrackingScreen> createState() => _StatusTrackingScreenState();
}

class _StatusTrackingScreenState extends State<StatusTrackingScreen> {
  final AuthService _authService = AuthService();
  
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
        stream: _authService.getStudentStream(user.uid),
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
          String submittedDate = 'N/A';
          if (data['createdAt'] != null) {
             final Timestamp ts = data['createdAt'];
             submittedDate = DateFormat('MMM d, yyyy').format(ts.toDate());
          }
          final String? feedback = data['feedback'];

          Color statusColor = AppTheme.warning;
          if (status == 'Approved') statusColor = AppTheme.success;
          if (status == 'Rejected') statusColor = AppTheme.error;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildStatusItem(
                context,
                'First Semester 2024 Documents',
                'Submitted on $submittedDate',
                status,
                statusColor,
                feedback: status == 'Rejected' ? feedback : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String title,
    String date,
    String status,
    Color statusColor, {
    String? feedback,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
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
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (feedback != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.messageSquare, size: 14, color: AppTheme.error),
                        SizedBox(width: 8),
                        Text(
                          'Feedback:',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      feedback,
                      style: TextStyle(fontSize: 13, color: context.textPri),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text('Resubmit Documents', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View Details', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
