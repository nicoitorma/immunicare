import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RelativeViewModel extends ChangeNotifier {
  List<UserModel> relatives = [];
  int? oneTimePin;
  String? errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future getRelatives() async {
    // Fetch relatives from database based on the relatives IDs stored in parent's document

    try {
      final prefs = await SharedPreferences.getInstance();
      String parentId = prefs.getString('uid') ?? '';
      final parentDoc =
          await _firestore.collection('users').doc(parentId).get();
      List<String> relativeIds = List<String>.from(
        parentDoc.data()?['relatives'] ?? [],
      );
      relatives = await Future.wait(
        relativeIds.map((id) async {
          final doc = await _firestore.collection('users').doc(id).get();
          return UserModel.fromMap(doc.data()!, doc.id);
        }).toList(),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  Future<String> createNewAccount(
    UserModel existingUser,
    UserModel user,
    int password,
  ) async {
    try {
      //Create new account without signing in the created account
      FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );
      try {
        UserCredential userCred = await FirebaseAuth.instanceFor(app: app)
            .createUserWithEmailAndPassword(
              email: user.email,
              password: password.toString(),
            )
            .then((value) async {
              final newUser = user.copyWith(id: value.user!.uid);

              try {
                final userData = newUser.toMap();
                userData['pin'] = password.toString();
                userData['parentId'] = existingUser.id;
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

        // Update parent's relatives list and add the new relative without overwriting existing ones
        await _firestore.collection('users').doc(existingUser.id).update({
          'relatives': FieldValue.arrayUnion([userCred.user?.uid]),
        });

        // Update local relatives list
        relatives.add(user);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else {
          errorMessage = 'Sign up failed: ${e.message}';
        }
      } catch (e) {
        throw e;
      }

      await app.delete();
      notifyListeners();
      return 'success';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
    return errorMessage ?? 'success';
  }
}
