// ignore_for_file: unused_import
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> logIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // attempt login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user; //gets info if user is loged in
      // Commented out temporarily just for testing.
      // if (user != null && user.emailVerified) {
      //   // Redirect user to home page if email is verified
      //   if (context.mounted) {
      //     context.go(Routes.home);
      //   }
      // } else {
      //   _errorMessage = "Please verify your email before logging in.";
      //   await _auth.signOut();
      // }

      // Temp just for testing.
      if (user != null && (!(await _hasPet())) && context.mounted) {
        context.push(Routes.choosePet);
      } else if (context.mounted) {
        context.push(Routes.home);
      }

    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if the user has choosen a pet.
  Future<bool> _hasPet() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid);

    final snapshot = await userDoc.get();
    // Use the type because the user may choose to give a blank name.
    final petType = snapshot.data()?['pet']['type'] ?? '';

    if (petType == '') return false;

    return true;
  }
}
