import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Log (Audit Trail)', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          const Text('Track all administrative actions and system updates for transparency.'),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: 15,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return _buildLogItem(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(int index) {
    final actions = ['Approved Document', 'Rejected Document', 'Verified SA Number', 'Updated Records', 'Requested Resubmission'];
    final admins = ['Admin_Sarah', 'Principal_Admin', 'Staff_John', 'Admin_Jane'];
    final times = ['Just now', '10m ago', '1h ago', '3h ago', 'Yesterday'];
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.activity, color: AppTheme.primaryColor, size: 20),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          children: [
            TextSpan(text: '${admins[index % 4]} ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: actions[index % 5]),
            const TextSpan(text: ' for Student '),
            const TextSpan(text: '2021-00421', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(LucideIcons.clock, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(times[index % 5], style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            const Icon(LucideIcons.monitor, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            const Text('IP: 192.168.1.XX', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
