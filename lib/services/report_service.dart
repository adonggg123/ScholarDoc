import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of all generated reports
  Stream<QuerySnapshot> getReportsStream() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add a new report record to history
  Future<void> addReportRecord({
    required String title,
    required String fileName,
  }) async {
    await _firestore.collection('reports').add({
      'title': title,
      'fileName': fileName,
      'status': 'Generated',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Aggregation for Bar Chart (Throughput)
  // This aggregates registrations (Total Submissions) and "Approved" status changes (Approved)
  // Timeframe: 'This Week', 'This Month', 'This Year'
  Stream<Map<String, List<int>>> getThroughputData(String timeframe) {
    // Determine start date based on timeframe
    DateTime now = DateTime.now();
    DateTime startDate;

    if (timeframe == 'This Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
    } else if (timeframe == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      // Default: This Year
      startDate = DateTime(now.year, 1, 1);
    }

    // Since we want dynamic updates, we'll combine two streams: students (registrations) and audit_logs (approvals)
    return Stream.fromFuture(Future.wait([
      _firestore
          .collection('students')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .get(),
      _firestore
          .collection('audit_logs')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .get(),
    ])).asyncExpand((results) {
      final QuerySnapshot students = results[0] as QuerySnapshot;
      final QuerySnapshot logs = results[1] as QuerySnapshot;

      List<int> submissions = [0, 0, 0, 0];
      List<int> approved = [0, 0, 0, 0];

      for (var doc in students.docs) {
        final timestamp = (doc['createdAt'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          int index = _getDateIndex(timestamp, timeframe);
          if (index >= 0 && index < 4) submissions[index]++;
        }
      }

      for (var doc in logs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String action = data['action'] ?? '';
        
        // Filter for "Approved" actions client-side
        if (action.contains('Approved')) {
          final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
          if (timestamp != null) {
            int index = _getDateIndex(timestamp, timeframe);
            if (index >= 0 && index < 4) approved[index]++;
          }
        }
      }

      return Stream.value({
        'submissions': submissions,
        'approved': approved,
      });
    }).handleError((error) {
      // Return empty data on error to stop the loading spinner
      return {
        'submissions': [0, 0, 0, 0],
        'approved': [0, 0, 0, 0],
      };
    });
  }

  int _getDateIndex(DateTime date, String timeframe) {
    if (timeframe == 'This Year') {
      // Group by Quarter
      return ((date.month - 1) / 3).floor();
    } else if (timeframe == 'This Month') {
      // Group by Week (approx)
      return ((date.day - 1) / 7).floor();
    } else {
      // This Week: Group by days (Mon-Tue, Wed-Thu, Fri, Sat-Sun)
      int day = date.weekday;
      if (day <= 2) return 0;
      if (day <= 4) return 1;
      if (day == 5) return 2;
      return 3;
    }
  }

  // Static stats for the PDF
  Future<Map<String, int>> getInstitutionalStats() async {
    final students = await _firestore.collection('students').get();
    
    int total = students.docs.length;
    int approved = 0;
    int pending = 0;
    int rejected = 0;

    for (var doc in students.docs) {
      final status = doc['status'] as String? ?? 'Pending';
      if (status == 'Approved') approved++;
      else if (status == 'Rejected') rejected++;
      else pending++;
    }

    return {
      'total': total,
      'approved': approved,
      'pending': pending,
      'rejected': rejected,
    };
  }

  // Aggregation for the 6-month submission trend on the main dashboard
  Stream<List<double>> getMonthlySubmissionTrend() {
    DateTime now = DateTime.now();
    DateTime sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    return _firestore
        .collection('students')
        .where('createdAt', isGreaterThanOrEqualTo: sixMonthsAgo)
        .snapshots()
        .map((snapshot) {
      List<double> counts = List.filled(6, 0.0);
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          int monthDiff = (now.year - timestamp.year) * 12 + now.month - timestamp.month;
          if (monthDiff >= 0 && monthDiff < 6) {
            counts[5 - monthDiff]++;
          }
        }
      }
      return counts;
    });
  }
}
