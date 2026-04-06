import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  late Stream<QuerySnapshot> _notificationStream;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _notificationStream = _notificationService.getNotificationsStream(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to view notifications.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _notificationStream,
            builder: (context, snapshot) {
              final hasUnread = snapshot.hasData && 
                  snapshot.data!.docs.any((doc) => !(doc.data() as Map<String, dynamic>)['isRead']);
              
              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () => _notificationService.markAllAsRead(user.uid),
                child: const Text('Mark all as read'),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data?.docs.toList() ?? [];

          // --- LOCAL SORTING ---
          // Since we removed .orderBy() from the Firestore query (to avoid index issues),
          // we sort the documents locally by timestamp descending.
          docs.sort((a, b) {
            final Timestamp? tA = (a.data() as Map<String, dynamic>)['timestamp'];
            final Timestamp? tB = (b.data() as Map<String, dynamic>)['timestamp'];
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return _buildNotificationItem(
                context,
                doc.id,
                data['title'] ?? 'Notification',
                data['message'] ?? '',
                data['timestamp'],
                data['type'] ?? 'info',
                !(data['isRead'] ?? true),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String docId,
    String title,
    String message,
    dynamic timestamp,
    String type,
    bool isNew,
  ) {
    IconData icon = LucideIcons.info;
    Color color = AppTheme.primaryColor;

    switch (type) {
      case 'success':
        icon = LucideIcons.checkCircle2;
        color = AppTheme.success;
        break;
      case 'warning':
        icon = LucideIcons.alertCircle;
        color = AppTheme.warning;
        break;
      case 'error':
        icon = LucideIcons.xCircle;
        color = AppTheme.error;
        break;
    }

    String timeStr = 'Some time ago';
    if (timestamp is Timestamp) {
      final dateTime = timestamp.toDate();
      timeStr = DateFormat('MMM d, h:mm a').format(dateTime);
      
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours}h ago';
      }
    }

    return InkWell(
      onTap: isNew ? () => _notificationService.markAsRead(docId) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNew ? context.surfaceC : context.surfaceC.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNew ? color.withValues(alpha: 0.3) : context.crispBorder,
            width: isNew ? 1.5 : 1,
          ),
          boxShadow: isNew ? AppTheme.softShadow : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: isNew ? context.textPri : context.textPri.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: TextStyle(
                      color: isNew ? context.textPri.withValues(alpha: 0.9) : context.textSec,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 12, color: context.textSec),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: TextStyle(fontSize: 11, color: context.textSec),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
