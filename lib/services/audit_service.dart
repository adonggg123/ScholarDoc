import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:io'; // For Platform checking (only safe to use when not on Web)

class AuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Logs a secure system audit event into Firestore
  /// [action] Summary of what happened (e.g., 'Approved SA Number')
  /// [userName] Name of the person performing the action
  /// [role] 'Admin' or 'Student'
  /// [studentId] Optional ID of the student impacted by the action
  Future<void> logActivity({
    required String action,
    required String userName,
    required String role,
    String? studentId,
  }) async {
    try {
      // Safely determine platform
      String platformInfo = 'Unknown Device';
      if (kIsWeb) {
        platformInfo = 'Web Browser';
      } else {
        if (Platform.isAndroid) {
          platformInfo = 'Android Device';
        } else if (Platform.isIOS) platformInfo = 'iOS Device';
        else if (Platform.isWindows) platformInfo = 'Windows Client';
        else if (Platform.isMacOS) platformInfo = 'macOS Client';
      }

      await _firestore.collection('audit_logs').add({
        'action': action,
        'adminName': userName,
        'role': role,
        'studentId': studentId ?? 'N/A',
        'ipAddress': platformInfo,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log audit activity: $e');
    }
  }

  /// Stream of latest system audit logs
  Stream<QuerySnapshot> getAuditLogsStream({int limit = 10}) {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }
}
