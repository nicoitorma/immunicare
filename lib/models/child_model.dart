import 'package:immunicare/models/immunization_record_model.dart';

class Child {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String parentUid;
  final List<ImmunizationRecord> vaccines;
  final List<ImmunizationRecord> vitamins;

  Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.parentUid,
    required this.vaccines,
    required this.vitamins,
  });

  // Factory constructor to create a Child from a Firestore document.
  factory Child.fromMap(Map<String, dynamic> data, String id) {
    return Child(
      id: id,
      name: data['name'] ?? '',
      dateOfBirth: data['dateOfBirth'],
      parentUid: data['parentUid'] ?? '',
      vaccines:
          (data['vaccines'] as List<dynamic>?)
              ?.map(
                (v) => ImmunizationRecord.fromMap(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
      vitamins:
          (data['vitamins'] as List<dynamic>?)
              ?.map(
                (v) => ImmunizationRecord.fromMap(v as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // Converts a Child object into a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'parentUid': parentUid,
      'vaccines': vaccines.map((v) => v.toMap()).toList(),
      'vitamins': vitamins.map((v) => v.toMap()).toList(),
    };
  }
}
