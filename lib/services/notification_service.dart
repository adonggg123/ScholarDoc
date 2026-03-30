import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a notification to a specific student
  Future<void> sendNotification({
    required String studentId,
    required String title,
    required String message,
    required String type, // 'success', 'warning', 'error', 'info'
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'studentId': studentId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Stream of notifications for a specific student
  Stream<QuerySnapshot> getNotificationsStream(String studentId) {
    // Note: Removed .orderBy() to avoid needing a composite index for now.
    return _firestore
        .collection('notifications')
        .where('studentId', isEqualTo: studentId)
        .snapshots();
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read for a specific student
  Future<void> markAllAsRead(String studentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('studentId', isEqualTo: studentId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
