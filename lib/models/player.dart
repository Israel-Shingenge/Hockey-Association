import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String id;
  final String birthday;
  final DateTime createdAt;
  final String email;
  final String? firebaseAuthUid;
  final String firstName;
  final String gender;
  final int jerseyNumber;
  final String lastName;
  final int phone;
  final String position;
  final String teamId;

  Player({
    required this.id,
    required this.birthday,
    required this.createdAt,
    required this.email,
    this.firebaseAuthUid,
    required this.firstName,
    required this.gender,
    required this.jerseyNumber,
    required this.lastName,
    required this.phone,
    required this.position,
    required this.teamId,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Player(
      id: doc.id,
      birthday: data['birthday'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      email: data['email'] ?? '',
      firebaseAuthUid: data['firebaseAuthUid'],
      firstName: data['firstName'] ?? '',
      gender: data['gender'] ?? '',
      jerseyNumber: data['jerseyNumber'] ?? 0,
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? 0,
      position: data['position'] ?? '',
      teamId: data['teamId'] ?? '',
    );
  }

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      id: data['id'] ?? '',
      birthday: data['birthday'] ?? '',
      createdAt: data['createdAt'] ?? DateTime.now(),
      email: data['email'] ?? '',
      firebaseAuthUid: data['firebaseAuthUid'],
      firstName: data['firstName'] ?? '',
      gender: data['gender'] ?? '',
      jerseyNumber: data['jerseyNumber'] ?? 0,
      lastName: data['lastName'] ?? '',
      phone: data['phone'] ?? 0,
      position: data['position'] ?? '',
      teamId: data['teamId'] ?? '',
    );
  }
}