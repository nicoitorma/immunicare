class ImmunizationRecord {
  final String name;
  final DateTime? dateAdministered;
  final bool isAdministered;

  ImmunizationRecord({
    required this.name,
    this.dateAdministered,
    required this.isAdministered,
  });

  // Factory constructor to create an object from a Firestore map.
  factory ImmunizationRecord.fromMap(Map<String, dynamic> data) {
    return ImmunizationRecord(
      name: data['name'] ?? '',
      dateAdministered: data['dateAdministered'],
      isAdministered: data['isAdministered'] ?? false,
    );
  }

  // Converts the object to a Firestore map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dateAdministered': dateAdministered != null ? dateAdministered! : null,
      'isAdministered': isAdministered,
    };
  }
}
