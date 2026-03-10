import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Log (Audit Trail)', 
                style: isMobile 
                  ? Theme.of(context).textTheme.titleLarge 
                  : Theme.of(context).textTheme.headlineMedium
              ),
              const SizedBox(height: 4),
              const Text('Track all administrative actions and system updates for transparency.'),
              const SizedBox(height: 32),
              Container(
                decoration: AppTheme.glassDecoration(opacity: 0.6, boxShadow: AppTheme.softShadow),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 15,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  itemBuilder: (context, index) {
                    return _buildLogItem(context, index, isMobile);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogItem(BuildContext context, int index, bool isMobile) {
    final actions = ['Approved Document', 'Rejected Document', 'Verified SA Number', 'Updated Records', 'Requested Resubmission'];
    final admins = ['Admin_Sarah', 'Principal_Admin', 'Staff_John', 'Admin_Jane'];
    final times = ['Just now', '10m ago', '1h ago', '3h ago', 'Yesterday'];
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 4),
      leading: isMobile ? null : Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.activity, color: AppTheme.primaryColor, size: 16),
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
        child: Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.clock, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(times[index % 5], style: const TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.monitor, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                const Text('IP: 192.168.1.XX', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
