import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:immunicare/models/child_model.dart';
import 'package:immunicare/models/immunization_record_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adds a new child document to the 'children' collection.
  Future<void> addChild(Child child) async {
    try {
      await _firestore.collection('children').doc(child.id).set(child.toMap());
      print('Child added successfully!');
    } catch (e) {
      print('Error adding child: $e');
      rethrow;
    }
  }

  // Gets a stream of all children for a specific parent.
  Stream<List<Child>> getChildrenForParent(String parentUid) {
    return _firestore
        .collection('children')
        .where('parentUid', isEqualTo: parentUid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Child.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Updates the immunization status for a child.
  Future<void> updateImmunizationStatus(
    String childId,
    List<ImmunizationRecord> vaccines,
    List<ImmunizationRecord> vitamins,
  ) async {
    try {
      await _firestore.collection('children').doc(childId).update({
        'vaccines': vaccines.map((v) => v.toMap()).toList(),
        'vitamins': vitamins.map((v) => v.toMap()).toList(),
      });
      print('Immunization status updated successfully!');
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }
}
