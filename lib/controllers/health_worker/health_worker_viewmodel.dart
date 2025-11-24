import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/models/vax_log.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class HealthWorkerViewmodel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<UserModel> _health_workers = [];
  List<UserModel> get health_workers => _health_workers;
  List<UserModel> _filteredHealthWorkers = [];
  List<UserModel> get filteredHealthWorkers => _filteredHealthWorkers;
  List<VaxLog> _vaccination_logs = [];
  List<VaxLog> get vaxLog => _vaccination_logs;
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

  Future getVaccinationLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final snapshot =
          await _firestore
              .collection('vaccination_logs')
              .where('health_worker_uid', isEqualTo: uid)
              .get();
      _vaccination_logs =
          snapshot.docs.map((doc) => VaxLog.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching logs.');
    } finally {
      notifyListeners();
    }
  }

  Future<Uint8List> exportVaxLog(String name) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Text(
                '${name} Vaccination Logs',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Table.fromTextArray(
                headers: [
                  'Child name',
                  'Vaccine',
                  'Administered By',
                  'Date and Time',
                ],
                data:
                    vaxLog.map((log) {
                      return [
                        log.childName ?? '',
                        log.vaccineName ?? '',
                        log.administeredBy ?? '',
                        DateFormat(
                          'MMMM d, y, h:mm a',
                        ).format(log.administeredAt.toDate()).toString(),
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    return pdf.save();
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
                final userData = newUser.toMap();
                userData['pin'] = password.toString();
                await _firestore
                    .collection('users')
                    .doc(value.user!.uid)
                    .set(userData);
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

  Future<void> deleteUser(UserModel user) async {
    FirebaseApp? secondaryApp;
    try {
      await _firestore.collection('users').doc(user.id).delete();
      secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final userCredential = await secondaryAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.pin ?? '',
      );
      await userCredential.user?.delete();
      final index = _health_workers.indexWhere((doc) => doc.id == user.id);

      if (index != -1) {
        _health_workers.removeAt(index);
      }
    } catch (e) {
      print(e.toString());
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
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
