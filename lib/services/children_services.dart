import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:immunicare/models/user_model.dart';

class ChildrenServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllParents() async {
    try {
      final QuerySnapshot usersSnapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'parent')
              .get();

      final List<UserModel> parents =
          usersSnapshot.docs.map((doc) {
            return UserModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

      return parents;
    } catch (e) {
      print('Error getting all parents: $e');
      return [];
    }
  }

  Future<List<String>> getAllParentUids() async {
    try {
      final QuerySnapshot usersSnapshot =
          await _firestore.collection('users').get();

      final List<String> uids =
          usersSnapshot.docs.map((doc) => doc.id).toList();

      return uids;
    } catch (e) {
      print('Error getting all parent UIDs: $e');
      return [];
    }
  }

  Future<int> getChildrenCountForParent(String uid) async {
    try {
      final aggregateQuery =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('children')
              .count()
              .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      print('Error getting children count: $e');
      return 0;
    }
  }
}
