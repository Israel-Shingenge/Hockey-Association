import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String clubDescription;
  final String clubLeague;
  final String clubName;
  final String contactPerson;
  final DateTime createdAt;
  final String email;
  final String logoUrl;
  final String managerFirebaseUid;
  final String phoneNumber; 

  Team({
    required this.clubDescription,
    required this.clubLeague,
    required this.clubName,
    required this.contactPerson,
    required this.createdAt,
    required this.email,
    required this.logoUrl,
    required this.managerFirebaseUid,
    required this.phoneNumber, 
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Team(
      clubDescription: data['clubDescription'] ?? '',
      clubLeague: data['clubLeague'] ?? '',
      clubName: data['clubName'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(), 
      email: data['email'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      managerFirebaseUid: data['managerFirebaseUid'] ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '', 
    );
  }

  factory Team.fromMap(Map<String, dynamic> data) {
    return Team(
      clubDescription: data['clubDescription'] ?? '',
      clubLeague: data['clubLeague'] ?? '',
      clubName: data['clubName'] ?? '',
      contactPerson: data['contactPerson'] ?? '',
      // Ensure createdAt is always a DateTime
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : (data['createdAt'] is DateTime)
              ? data['createdAt'] as DateTime
              : DateTime.now(),
      email: data['email'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      managerFirebaseUid: data['managerFirebaseUid'] ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '', 
    );
  }
}