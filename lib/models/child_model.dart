import 'package:cloud_firestore/cloud_firestore.dart';

class Child {
  final String id;
  final String lastname;
  final String firstname;
  final Timestamp dateOfBirth;
  final String parentId;
  final List schedule;

  Child({
    required this.id,
    required this.lastname,
    required this.firstname,
    required this.dateOfBirth,
    required this.parentId,
    required this.schedule,
  });

  // Factory constructor to create a Child from Firestore document.
  factory Child.fromMap(Map<String, dynamic> data, String id) {
    return Child(
      id: id,
      lastname: data['lastname'] ?? '',
      firstname: data['firstname'] ?? '',
      dateOfBirth: data['dob'] ?? '',
      parentId: data['parentId'] ?? '',
      schedule: data['schedule'] ?? [],
    );
  }

  // Converts a Child object into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'lastname': lastname,
      'firstname': firstname,
      'dob': dateOfBirth,
      'parentId': parentId,
      'schedule': schedule,
    };
  }
}
