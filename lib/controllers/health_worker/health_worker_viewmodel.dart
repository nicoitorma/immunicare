import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/user_model.dart';

class HealthWorkerViewmodel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<UserModel> _health_workers = [];
  List<UserModel> get health_workers => _health_workers;
  List<UserModel> _filteredHealthWorkers = [];
  List<UserModel> get filteredHealthWorkers => _filteredHealthWorkers;

  String? result;
  String? errorMessage;

  Future getAllHealthWorker() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      _health_workers =
          snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList();
      _filteredHealthWorkers = _health_workers;
      _filteredHealthWorkers.removeWhere((user) => user.role == 'super_admin');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future createNewAccount(UserModel user, String password) async {
    try {
      final auth = FirebaseAuth.instance;

      auth
          .createUserWithEmailAndPassword(email: user.email, password: password)
          .then((newUser) async {
            print('Created: ${newUser.user!.uid}');
            try {
              await _firestore
                  .collection('users')
                  .doc(newUser.user!.uid)
                  .set(user.toMap());
              _health_workers.add(user);
              result = 'success';
            } catch (e) {
              newUser.user!.delete();
              throw FirebaseAuthException(
                code: 'failed-to-create-user',
                message: 'Failed to create user.',
              );
            }
            notifyListeners();
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage = 'An account already exists for that email.';
      } else {
        errorMessage = 'Sign up failed: ${e.message}';
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> editUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'role': user.role,
      });

      final index = _health_workers.indexWhere((doc) => doc.id == user.id);
      if (index != -1) {
        _health_workers[index] = user;
      }
    } catch (e) {
      debugPrint('Error editing educational resource: $e');
    } finally {
      notifyListeners();
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
