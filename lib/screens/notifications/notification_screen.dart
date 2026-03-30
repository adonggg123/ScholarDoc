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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
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

    return GestureDetector(
      onTap: isNew ? () => _notificationService.markAsRead(docId) : null,
      child: Card(
        elevation: isNew ? 2 : 0,
        color: isNew ? Colors.white : context.bgC.withValues(alpha: 0.5),
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
              Text(message, style: TextStyle(color: isNew ? context.textPri : context.textSec)),
              const SizedBox(height: 8),
              Text(
                timeStr,
                style: TextStyle(fontSize: 12, color: context.textSec),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
