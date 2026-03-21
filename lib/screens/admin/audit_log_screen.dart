import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        
        return StreamBuilder<QuerySnapshot>(
          stream: _authService.getAuditLogsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading activity logs'));
            }

            final docs = snapshot.data?.docs ?? [];

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
                  SizedBox(height: 4),
                  Text('Track all administrative actions and system updates for transparency.'),
                  SizedBox(height: 32),
                  if (docs.isEmpty) 
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(LucideIcons.scrollText, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                            SizedBox(height: 16),
                            Text('No activity recorded yet.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: context.glassDecoration,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => Divider(color: context.surfaceC.withValues(alpha: 0.1), height: 1),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return _buildLogItem(context, data, isMobile);
                        },
                      ),
                    ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> data, bool isMobile) {
    final String action = data['action'] ?? 'Performed Action';
    final String adminName = data['adminName'] ?? 'Admin';
    final String studentId = data['studentId'] ?? 'N/A';
    final String ipAddress = data['ipAddress'] ?? '192.168.1.XX';
    final dynamic timestamp = data['timestamp'];
    
    String timeStr = 'Just now';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      timeStr = DateFormat('MMM d, h:mm a').format(dateTime);
      
      // Calculate relative time for recent items
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      }
    }
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 4),
      leading: isMobile ? null : Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(LucideIcons.activity, color: AppTheme.primaryColor, size: 16),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(color: context.textPri, fontSize: 14),
          children: [
            TextSpan(text: '$adminName ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: action),
            if (studentId != 'N/A') ...[
              const TextSpan(text: ' for Student '),
              TextSpan(text: studentId, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 12, color: context.textSec),
                SizedBox(width: 4),
                Text(timeStr, style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.monitor, size: 12, color: context.textSec),
                SizedBox(width: 4),
                Text('IP: $ipAddress', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
