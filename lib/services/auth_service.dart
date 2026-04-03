import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audit_service.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditService _auditService = AuditService();
  final NotificationService _notificationService = NotificationService();

  // Helper to generate a unique email based on student ID (for Firebase Auth)
  String _getAuthEmail(String studentId) {
    return '${studentId.trim().replaceAll(' ', '_')}@scholardoc.local';
  }

  // Sign up student
  Future<UserCredential?> registerStudent({
    required String gmail, // Used for notifications, not login
    required String studentId,
    required Map<String, dynamic> studentData,
  }) async {
    try {
      final String authEmail = _getAuthEmail(studentId);
      final String authPassword = studentId.trim();

      // 1. Create user in Firebase Auth using ID as Password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: authEmail,
        password: authPassword,
      );

      // 2. Save student details to Firestore under 'students' collection
      if (userCredential.user != null) {
        studentData['uid'] = userCredential.user!.uid;
        studentData['authEmail'] = authEmail; // Track the internal auth email
        studentData['createdAt'] = FieldValue.serverTimestamp();
        
        await _firestore
            .collection('students')
            .doc(userCredential.user!.uid)
            .set(studentData);
            
        // Log Activity
        await _auditService.logActivity(
          action: 'Registered new account (ID: $studentId)',
          userName: studentData['fullName'] ?? gmail,
          role: 'Student',
          studentId: studentId,
        );

        // Send Welcome Notification
        await _notificationService.sendNotification(
          studentId: userCredential.user!.uid,
          title: 'Welcome to ScholarDoc!',
          message: 'Your account has been created successfully. Use your Student ID ($studentId) to login next time.',
          type: 'success',
        );
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login student
  Future<UserCredential?> loginStudent({
    required String studentId,
    required String password,
  }) async {
    final String trimmedId = studentId.trim();
    final String trimmedPassword = password.trim();
    final String authEmail = _getAuthEmail(trimmedId);

    UserCredential? userCredential;

    // --- Step 1: Try new ID-based email (accounts registered after the update) ---
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: trimmedPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found' && e.code != 'wrong-password' && e.code != 'invalid-credential') {
        rethrow;
      }
      // Fall through to legacy fallback below
    }

    // --- Step 2: Fallback — look up student by ID in Firestore and try their Gmail ---
    if (userCredential == null) {
      try {
        final query = await _firestore
            .collection('students')
            .where('studentId', isEqualTo: trimmedId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception('No account found for Student ID "$trimmedId". Please register first.');
        }

        final data = query.docs.first.data();
        final String? gmail = data['email'] as String?;

        if (gmail == null || gmail.isEmpty) {
          throw Exception('Account data is incomplete. Please contact your administrator.');
        }

        // Try logging in with the original Gmail + password
        try {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: gmail,
            password: trimmedPassword,
          );
        } on FirebaseAuthException {
          throw Exception('Login failed. Please verify your ID and password.');
        }
      } on FirebaseAuthException {
        rethrow;
      }
    }

    // --- Step 3: Verify the user record exists in Firestore students collection ---
    final DocumentSnapshot doc = await _firestore
        .collection('students')
        .doc(userCredential!.user!.uid)
        .get();

    if (!doc.exists) {
      await _auth.signOut();
      throw Exception('Student record not found. Please register first.');
    }

    final studentData = doc.data() as Map<String, dynamic>;

    // Log Activity
    await _auditService.logActivity(
      action: 'Logged in using Student ID',
      userName: studentData['fullName'] ?? 'Student',
      role: 'Student',
      studentId: trimmedId,
    );

    return userCredential;
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
      // Log Admin Activity
      await _auditService.logActivity(
        action: 'Logged into Admin Dashboard',
        userName: username,
        role: 'Admin',
      );
      
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

  // Update student profile data
  Future<void> updateStudentProfile(String uid, Map<String, dynamic> updates) async {
    await _firestore.collection('students').doc(uid).update(updates);
    
    // Log Activity
    await _auditService.logActivity(
      action: 'Updated profile information',
      userName: updates['fullName'] ?? 'Student',
      role: 'Student',
    );
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
