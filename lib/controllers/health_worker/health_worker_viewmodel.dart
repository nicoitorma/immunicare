import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthWorkerViewmodel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<UserModel> _health_workers = [];
  List<UserModel> get health_workers => _health_workers;
  List<UserModel> _filteredHealthWorkers = [];
  List<UserModel> get filteredHealthWorkers => _filteredHealthWorkers;
  String address = '';
  String role = '';

  String? result;
  String? errorMessage;

  Future getAllHealthWorkers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      role = prefs.getString('role') ?? '';
      address = prefs.getString('address') ?? '';
      if (role == 'super_admin') {
        final snapshot = await _firestore.collection('users').get();
        _health_workers =
            snapshot.docs
                .map((doc) => UserModel.fromMap(doc.data(), doc.id))
                .toList();
      } else {
        final snapshot =
            await _firestore
                .collection('users')
                .where('address', isEqualTo: address)
                .get();
        _health_workers =
            snapshot.docs
                .map((doc) => UserModel.fromMap(doc.data(), doc.id))
                .toList();
      }
      _filteredHealthWorkers = _health_workers;
      _filteredHealthWorkers.removeWhere((user) => user.role == 'super_admin');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<String> createNewAccount(UserModel user, String password) async {
    try {
      //Create new account without signing in the created account
      FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );
      try {
        await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(
              email: user.email,
              password: password,
            )
            .then((value) async {
              final newUser = user.copyWith(id: value.user!.uid);
              try {
                await _firestore
                    .collection('users')
                    .doc(value.user!.uid)
                    .set(newUser.toMap());
                return value;
              } catch (e) {
                value.user!.delete();
                throw FirebaseAuthException(
                  code: 'failed-to-create-user',
                  message: 'Failed to create user.',
                );
              }
            });
        _health_workers.add(user);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else {
          errorMessage = 'Sign up failed: ${e.message}';
        }
      }

      await app.delete();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
    return errorMessage ?? 'success';
  }

  Future<String> updateUser(UserModel updatedUser) async {
    try {
      final docRef = _firestore.collection('users').doc(updatedUser.id);

      await docRef.update({
        'firstname': updatedUser.firstname,
        'lastname': updatedUser.lastname,
        'address': updatedUser.address,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local list
      final index = _health_workers.indexWhere(
        (user) => user.id == updatedUser.id,
      );
      if (index != -1) {
        _health_workers[index] = updatedUser;
      }

      notifyListeners();
      return 'success';
    } on FirebaseException catch (e) {
      debugPrint('Firestore updateUser error: ${e.message}');
      return e.message ?? 'Firestore error occurred.';
    } catch (e) {
      debugPrint('updateUser error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      final index = _health_workers.indexWhere((doc) => doc.id == userId);

      if (index != -1) {
        _health_workers.removeAt(index);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future deleteArticle(String docId) async {
    try {
      _firestore.collection('educationals').doc(docId).delete();
      final index = _health_workers.indexWhere((doc) => doc.id == docId);

      if (index != -1) {
        _health_workers.removeAt(index);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  // Method to handle sorting
  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      // Sort by Lastname
      _filteredHealthWorkers.sort(
        (a, b) =>
            ascending
                ? a.lastname.compareTo(b.lastname)
                : b.lastname.compareTo(a.lastname),
      );
    } else if (columnIndex == 2) {
      // Sort by Address
      _filteredHealthWorkers.sort(
        (a, b) =>
            ascending
                ? a.address.compareTo(b.address)
                : b.address.compareTo(a.address),
      );
    }
  }
}
