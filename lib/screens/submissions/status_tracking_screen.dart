import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

class StatusTrackingScreen extends StatelessWidget {
  const StatusTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Submissions'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(LucideIcons.filter),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          _buildStatusItem(
            context,
            'Fall Semester 2023 Docs',
            'Submitted on Oct 12, 2023',
            'Pending Review',
            AppTheme.warning,
          ),
          SizedBox(height: 16),
          _buildStatusItem(
            context,
            'Spring Semester 2023 Docs',
            'Submitted on Feb 15, 2023',
            'Approved',
            AppTheme.success,
          ),
          SizedBox(height: 16),
          _buildStatusItem(
            context,
            'Midyear 2023 Docs',
            'Submitted on June 20, 2023',
            'Rejected',
            AppTheme.error,
            feedback: 'The school ID uploaded is blurred. Please resubmit a clearer photo.',
          ),
        ],
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
