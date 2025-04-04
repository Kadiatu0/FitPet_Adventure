import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Try to send a password reset email
      await _auth.sendPasswordResetEmail(email: email);

      // If successful, show a success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent. Check your inbox to reset your password!')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Handle the case where the email is not found
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found with this email address. Please try again.';
      } else {
        // Handle any other Firebase authentication errors
        _errorMessage = e.message;
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!)),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
