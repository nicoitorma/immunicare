import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:immunicare/models/user_model.dart';
import 'package:immunicare/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  UserModel? _userdata;
  String _role = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserModel? get userdata => _userdata;
  String get role => _role;

  AuthViewModel() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', user.uid);
        await getUserData();
        await fetchUserRole(user.uid);
      }
      print('Auth: complete');
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        if (email == 'superadmin@immunicare.com') {
          return;
        }
        await user.reload();

        // if (user.emailVerified) {
        //   _errorMessage = null;
        // } else {
        //   await user.sendEmailVerification();
        //   signOut();
        //   throw FirebaseAuthException(
        //     code: 'email-not-verified',
        //     message:
        //         'Your email is not verified. A new verification link has been sent.',
        //   );
        // }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Wrong password provided.';
      } else if (e.code == 'email-not-verified') {
        _errorMessage = e.message;
      } else {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future getUserData() async {
    try {
      final doc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();

      if (doc.exists) {
        _userdata = UserModel.fromMap(doc.data()!, _currentUser!.uid);
      } else {
        _userdata = null;
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> signUp({
    required UserCredential userCredential,
    required UserModel user,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // final userCredential = await _authService.signUpWithEmailAndPassword(
      //   email: user.email,
      //   password: password,
      // );

      if (userCredential.user != null) {
        _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toMap());
        userCredential.user!.sendEmailVerification();
        await fetchUserRole(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'An account already exists for that email.';
      } else {
        _errorMessage = 'Sign up failed: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future fetchUserRole(String uid) async {
    if (uid.isEmpty) return '';
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _role = doc.data()?['role'] ?? '';
      } else {
        _role = 'null';
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    _role = '';
    _userdata = null;
    await _authService.signOut();
  }

  Future updatePersonalInfo(String firstname, lastname, address) async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'firstname': firstname,
        'lastname': lastname,
        'address': address,
      });
    } catch (e) {
      print('error updating personal info: $e');
    }
  }

  Future uploadProfilePhoto(File image) async {
    try {
      final storage = FirebaseStorage.instance;
      final Reference ref = storage.ref().child(
        'images/${auth.currentUser!.uid}.jpg',
      );
      await ref.putFile(image);
      auth.currentUser!.updatePhotoURL(await ref.getDownloadURL());
      return true;
    } on FirebaseException catch (e) {
      throw e;
    } catch (err) {
      throw err;
    } finally {
      notifyListeners();
    }
  }
}
