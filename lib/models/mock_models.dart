class DocumentSubmission {
  final String id;
  final String title;
  final String type;
  final DateTime submittedAt;
  final SubmissionStatus status;
  final String? feedback;

  const DocumentSubmission({
    required this.id,
    required this.title,
    required this.type,
    required this.submittedAt,
    required this.status,
    this.feedback,
  });
}

enum SubmissionStatus {
  pending,
  underReview,
  approved,
  rejected,
}

class UserProfile {
  final String id;
  final String name;
  final String studentId;
  final String course;
  final int yearLevel;
  final String email;
  final String? saNumber;

  const UserProfile({
    required this.id,
    required this.name,
    required this.studentId,
    required this.course,
    required this.yearLevel,
    required this.email,
    this.saNumber,
  });
}

class SystemNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const SystemNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });
}
