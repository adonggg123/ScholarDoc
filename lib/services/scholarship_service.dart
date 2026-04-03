import 'package:cloud_firestore/cloud_firestore.dart';

class Scholarship {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final List<String> requiredDocuments;

  Scholarship({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.requiredDocuments,
  });

  factory Scholarship.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Scholarship(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      requiredDocuments: List<String>.from(data['requiredDocuments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'requiredDocuments': requiredDocuments,
    };
  }
}

class ScholarshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get active scholarships
  Stream<List<Scholarship>> getActiveScholarships() {
    return _firestore
        .collection('scholarships')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Scholarship.fromFirestore(doc)).toList());
  }

  // Get all scholarships
  Stream<List<Scholarship>> getAllScholarships() {
    return _firestore
        .collection('scholarships')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Scholarship.fromFirestore(doc)).toList());
  }

  // Get a single scholarship by ID
  Future<Scholarship?> getScholarshipById(String id) async {
    try {
      final doc = await _firestore.collection('scholarships').doc(id).get();
      if (doc.exists) {
        return Scholarship.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching scholarship by ID: $e');
    }
    return null;
  }

  // Add a scholarship
  Future<void> addScholarship(Scholarship scholarship) async {
    await _firestore.collection('scholarships').add(scholarship.toMap());
  }

  // Update a scholarship
  Future<void> updateScholarship(String id, Map<String, dynamic> updates) async {
    await _firestore.collection('scholarships').doc(id).update(updates);
  }

  // Delete a scholarship
  Future<void> deleteScholarship(String id) async {
    await _firestore.collection('scholarships').doc(id).delete();
  }

  // Initialize default scholarships if none exist
  Future<void> initializeDefaults() async {
    final snapshot = await _firestore.collection('scholarships').get();
    if (snapshot.docs.isEmpty) {
      final defaults = [
        Scholarship(
          id: '',
          name: 'TES',
          description: 'Tertiary Education Subsidy',
          isActive: true,
          requiredDocuments: ['SA Number', 'Enrollment Form', 'ID Card'],
        ),
        Scholarship(
          id: '',
          name: 'TDP',
          description: 'Tulong Dunong Program',
          isActive: true,
          requiredDocuments: ['Application Form', 'Grades', 'ID Card'],
        ),
        Scholarship(
          id: '',
          name: 'DBP',
          description: 'DBP Rise Scholarship Program',
          isActive: true,
          requiredDocuments: ['Application Form', 'Income Tax Return', 'Recommendation'],
        ),
        Scholarship(
          id: '',
          name: 'SANTEH',
          description: 'SANTEH Aquaculture S&T Foundation',
          isActive: true,
          requiredDocuments: ['Application Form', 'Certificate of Residency', 'ID Card'],
        ),
        Scholarship(
          id: '',
          name: 'STUFAH',
          description: 'Student Financial Assistance Program',
          isActive: true,
          requiredDocuments: ['Application Form', 'Enrollment Form', 'Grades'],
        ),
      ];

      for (var s in defaults) {
        await addScholarship(s);
      }
    }
  }
}
