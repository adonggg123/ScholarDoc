import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            'Document Approved',
            'Your Billing Record for AY 2023-2024 has been verified.',
            '2 hours ago',
            LucideIcons.checkCircle2,
            AppTheme.success,
            true,
          ),
          _buildNotificationItem(
            'Submission Required',
            'Please upload your Validated School ID to complete your requirements.',
            '5 hours ago',
            LucideIcons.alertCircle,
            AppTheme.warning,
            true,
          ),
          _buildNotificationItem(
            'System Maintenance',
            'ScholarDoc will be down for maintenance on Saturday from 2 AM to 4 AM.',
            '1 day ago',
            LucideIcons.info,
            AppTheme.primaryColor,
            false,
          ),
          _buildNotificationItem(
            'Congratulations!',
            'Your scholarship application for the next semester has been preliminarily approved.',
            '2 days ago',
            LucideIcons.partyPopper,
            AppTheme.secondaryColor,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
    bool isNew,
  ) {
    return Card(
      elevation: isNew ? 2 : 0,
      color: isNew ? Colors.white : AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isNew ? color.withValues(alpha: 0.2) : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isNew)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
