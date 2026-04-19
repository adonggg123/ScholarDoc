import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PresenceService {
  final FirebaseDatabase _rtdb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track user presence
  Future<void> setUserPresence(String uid) async {
    // Reference to RTDB presence
    final DatabaseReference presenceRef = _rtdb.ref('status/$uid');

    // Reference to Firestore presence
    final DocumentReference firestoreRef = _firestore
        .collection('students')
        .doc(uid);

    // Online status for RTDB
    final Map<String, dynamic> isOnlineRTDB = {
      'state': 'online',
      'last_changed': ServerValue.timestamp,
    };

    // Offline status for RTDB (when disconnected)
    final Map<String, dynamic> isOfflineRTDB = {
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    };

    // Online status for Firestore
    final Map<String, dynamic> isOnlineFirestore = {
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    };

    // Offline status for Firestore

    try {
      // 1. Listen to the Special '.info/connected' node in RTDB
      _rtdb.ref('.info/connected').onValue.listen((event) async {
        final connected = event.snapshot.value as bool? ?? false;

        if (connected) {
          try {
            // 2. Set onDisconnect on RTDB
            await presenceRef.onDisconnect().set(isOfflineRTDB);

            // 3. Set Online Status on RTDB
            await presenceRef.set(isOnlineRTDB);

            // 4. Update Firestore as Online
            await firestoreRef.update(isOnlineFirestore);
          } catch (e) {
            debugPrint('Presence update error: $e');
          }
        } else {
          // If connection is lost locally (though onDisconnect handles server-side)
          // We can try to update Firestore, but it might not succeed if network is dead.
        }
      });

      // Note: We also need a way to update Firestore when onDisconnect triggers in RTDB.
      // This is usually done with a Cloud Function, but for this client-side implementation,
      // we will rely on Firestore 'isOnline' being updated when the user is active,
      // and potentially a 'lastSeen' check.
      // However, to make it truly 'Real-time' without Cloud Functions,
      // we can listen to the RTDB status from the Directory UI.
    } catch (e) {
      debugPrint('Error in PresenceService: $e');
    }
  }

  // Clear presence on logout
  Future<void> setOffline(String uid) async {
    try {
      await _rtdb.ref('status/$uid').set({
        'state': 'offline',
        'last_changed': ServerValue.timestamp,
      });
      await _firestore.collection('students').doc(uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error setting offline: $e');
    }
  }
}
