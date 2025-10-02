import 'package:cloud_firestore/cloud_firestore.dart';

class ImmunizationRecord {
  final String id;
  final String name;
  final DateTime date;
  final String type; // "vaccine" or "vitamin"

  ImmunizationRecord({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
  });

  factory ImmunizationRecord.fromMap(Map<String, dynamic> data, String id) {
    return ImmunizationRecord(
      id: id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'vaccine',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'date': date, 'type': type};
  }
}
