import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';

class ChangeEmailViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> changeEmail(String newEmail, String password, BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Re-authenticate the user before changing the email
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);

        // Perform reauthentication
        await user.reauthenticateWithCredential(credential);

        // Change the user's email
        await user.verifyBeforeUpdateEmail(newEmail);

        // Now, update the email in Firestore
        await _updateEmailInFirestore(user.uid, newEmail);

        // If successful, show a success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email changed successfully!')),
          );
          context.go(Routes.home);  // Redirect to welcome or any other page
        }
      } else {
        _errorMessage = 'No user is currently signed in.';
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage!)),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      if (e.code == 'requires-recent-login') {
        _errorMessage = 'Please log in again to change your email address.';
      } else {
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

  Future<void> _updateEmailInFirestore(String uid, String newEmail) async {
    try {
      // Update the user's email in Firestore
      await _firestore.collection('users').doc(uid).update({
        'email': newEmail,  // Update the email field with the new email
      });
    } catch (e) {
      // Handle Firestore errors if any
      print('Error updating email in Firestore: $e');
    }
  }
}
