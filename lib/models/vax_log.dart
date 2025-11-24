import 'package:cloud_firestore/cloud_firestore.dart';

class VaxLog {
  final String? administeredBy;
  final String? childName;
  final String? childId;
  final String? healthWorkerId;
  final String? vaccineName;
  final Timestamp administeredAt;

  VaxLog({
    this.administeredBy,
    this.childName,
    this.childId,
    this.healthWorkerId,
    this.vaccineName,
    required this.administeredAt,
  });

  // Factory constructor to create a User from Firestore document.
  factory VaxLog.fromMap(Map<String, dynamic> data) {
    return VaxLog(
      administeredBy: data['administeredBy'] ?? '',
      childName: data['child'] ?? '',
      administeredAt: data['administeredAt'] ?? '',
      childId: data['childId'] ?? '',
      healthWorkerId: data['healthWorkerId'] ?? '',
      vaccineName: data['vaccineName'] ?? '',
    );
  }
}
