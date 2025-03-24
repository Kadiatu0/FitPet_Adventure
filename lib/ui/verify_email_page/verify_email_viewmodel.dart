import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // Shows a loading indicator while checking verification.
  bool get isLoading => _isLoading;

  bool _isVerified = false; // Keeps track of whether the email is verified.
  bool get isVerified => _isVerified;

  String? _errorMessage;
  String? get errorMessage => _errorMessage; // Stores any error messages.

  // Check if email is verified
  Future<bool> checkEmailVerification() async {
    try {
      _isLoading = true; // Show loading spinner
      notifyListeners(); // Notify UI about state change

      User? user = _auth.currentUser; // Get the current user
      if (user != null){
          await user.reload(); // Refresh user data
        _isVerified = user.emailVerified; // Check verification status
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _isVerified; // Return status to UI
  }
}

