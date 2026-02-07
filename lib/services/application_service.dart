import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationType { disposal, relocation }

enum ApplicationStatus { pending, inProgress, completed, cancelled }

class Application {
  final String id;
  final String userId;
  final ApplicationType type;
  final ApplicationStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final List<String> imageUrls;

  Application({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.data,
    required this.imageUrls,
  });

  factory Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: ApplicationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ApplicationType.disposal,
      ),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: data['formData'] ?? {},
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'formData': data,
      'imageUrls': imageUrls,
    };
  }

  String get statusText {
    switch (status) {
      case ApplicationStatus.pending:
        return '접수 대기';
      case ApplicationStatus.inProgress:
        return '처리중';
      case ApplicationStatus.completed:
        return '완료';
      case ApplicationStatus.cancelled:
        return '취소됨';
    }
  }

  String get typeText {
    switch (type) {
      case ApplicationType.disposal:
        return '처분신청';
      case ApplicationType.relocation:
        return '이전설치';
    }
  }
}

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _applicationsRef =>
      _firestore.collection('applications');

  // Submit disposal application
  Future<String> submitDisposalApplication({
    required String userId,
    required List<String> imageUrls,
    String? notes,
  }) async {
    final doc = await _applicationsRef.add({
      'userId': userId,
      'type': ApplicationType.disposal.name,
      'status': ApplicationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'formData': {
        'notes': notes,
      },
      'imageUrls': imageUrls,
    });
    return doc.id;
  }

  // Submit relocation application
  Future<String> submitRelocationApplication({
    required String userId,
    required String fromAddress,
    required String toAddress,
    required String modelName,
    required bool hasElevatorFrom,
    required bool hasElevatorTo,
    String? notes,
  }) async {
    final doc = await _applicationsRef.add({
      'userId': userId,
      'type': ApplicationType.relocation.name,
      'status': ApplicationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'formData': {
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'modelName': modelName,
        'hasElevatorFrom': hasElevatorFrom,
        'hasElevatorTo': hasElevatorTo,
        'notes': notes,
      },
      'imageUrls': [],
    });
    return doc.id;
  }

  // Get user's applications
  Stream<List<Application>> getUserApplications(String userId) {
    return _applicationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Application.fromFirestore(doc)).toList());
  }

  // Get single application
  Future<Application?> getApplication(String applicationId) async {
    final doc = await _applicationsRef.doc(applicationId).get();
    if (!doc.exists) return null;
    return Application.fromFirestore(doc);
  }

  // Cancel application
  Future<void> cancelApplication(String applicationId) async {
    await _applicationsRef.doc(applicationId).update({
      'status': ApplicationStatus.cancelled.name,
    });
  }
}
