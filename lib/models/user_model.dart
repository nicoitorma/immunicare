import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String lastname;
  final String firstname;
  final String role;
  final String address;
  final String email;
  final String? pic;
  final String? pin;
  final String? parentId;
  final Timestamp? createdAt;
  final String? licenseNumber;
  final List<String>? relatives;

  UserModel({
    this.id,
    required this.lastname,
    required this.firstname,
    required this.email,
    required this.address,
    required this.role,
    this.pic,
    this.pin,
    this.relatives,
    this.parentId,
    this.licenseNumber,
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
      relatives: List<String>.from(data['relatives'] ?? []),
      pin: data['pin'] ?? '',
      parentId: data['parentId'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  UserModel copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    String? address,
    String? role,
    String? pin,
    String? parentId,
    String? licenseNumber,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      pin: pin,
      parentId: parentId,
      createdAt: createdAt ?? this.createdAt,
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
      'licenseNumber': licenseNumber,
      'relatives': relatives,
      'parentId': parentId,
      'createdAt': createdAt,
    };
  }
}
