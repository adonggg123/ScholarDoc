import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up student
  Future<UserCredential?> registerStudent({
    required String email,
    required String password,
    required Map<String, dynamic> studentData,
  }) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save student details to Firestore under 'students' collection
      if (userCredential.user != null) {
        studentData['uid'] = userCredential.user!.uid;
        studentData['createdAt'] = FieldValue.serverTimestamp();
        
        await _firestore
            .collection('students')
            .doc(userCredential.user!.uid)
            .set(studentData);
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An error occurred during registration.');
    }
  }

  // Login student
  Future<UserCredential?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify the user exists in the students collection
      DocumentSnapshot doc = await _firestore
          .collection('students')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('Student record not found. Please register first.');
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed.');
    }
  }

  // Admin login (Default account credentials check)
  Future<bool> loginAdmin({
    required String username,
    required String password,
  }) async {
    // Requirements specified a default admin account (username: Admin, password: 123)
    // For a real production app, this would query a secure backend or use Custom Claims.
    
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (username == 'Admin' && password == '123') {
      return true;
    } else {
      throw Exception('Invalid Admin credentials.');
    }
  }

  // Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get student profile data from Firestore
  Future<DocumentSnapshot> getStudentProfile(String uid) {
    return _firestore.collection('students').doc(uid).get();
  }

  // Get stream of student profile data for real-time tracking
  Stream<DocumentSnapshot> getStudentStream(String uid) {
    return _firestore.collection('students').doc(uid).snapshots();
  }

  // Get stream of all students for Admin
  Stream<QuerySnapshot> getStudentsStream() {
    return _firestore
        .collection('students')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get stream of all activity logs for Admin
  Stream<QuerySnapshot> getAuditLogsStream() {
    return _firestore
        .collection('audit_logs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;
}
