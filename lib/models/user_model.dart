import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String lastname;
  final String firstname;
  final String role;
  final String address;
  final String email;
  final String? pic;
  final Timestamp? createdAt;

  UserModel({
    this.id,
    required this.lastname,
    required this.firstname,
    required this.email,
    required this.address,
    required this.role,
    this.pic,
    this.createdAt,
  });

  // Factory constructor to create a User from Firestore document.
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      lastname: data['lastname'] ?? '<No lastname>',
      firstname: data['firstname'] ?? '<No firstname>',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      role: data['role'] ?? '',
      pic: data['pic'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Converts a User object into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastname': lastname,
      'firstname': firstname,
      'email': email,
      'address': address,
      'role': role,
      'pic': pic,
      'createdAt': createdAt,
    };
  }
}
