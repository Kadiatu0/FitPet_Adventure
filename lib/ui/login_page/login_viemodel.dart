// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> logIn(String email, String password, BuildContext context) async {
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
      if (user != null && user.emailVerified) {
        // Redirect user to home page if email is verified
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _errorMessage = "Please verify your email before logging in.";
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
