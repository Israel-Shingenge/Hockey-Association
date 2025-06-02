import 'package:cloud_firestore/cloud_firestore.dart';

class UserQuery {
  final String id;
  final String email;
  final String message;
  final DateTime timestamp;

  UserQuery({
    required this.id,
    required this.email,
    required this.message,
    required this.timestamp,
  });

  factory UserQuery.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserQuery(
      id: doc.id,
      email: data['email'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory UserQuery.fromMap(Map<String, dynamic> data) {
    return UserQuery(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? DateTime.now(),
    );
  }
}