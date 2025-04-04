// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user.dart' as app_user;  
import '../../domain/models/pet.dart' as user_pet; 

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; //for authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //for database

  bool _isLoading = false; //check if process running
  String? _errorMessage; //stores error messages

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String name, String email, String password, BuildContext context) async {
    try {
      _isLoading = true; // Indicates signup has started
      _errorMessage = null;
      notifyListeners(); 

      // Check if the name already exists
      bool isNameUnique = await _isNameUnique(name);
      if (!isNameUnique) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The name is already taken. Please choose another name.')),
          );
        }
        _isLoading = false;
        notifyListeners();
        return; // Return early if name is not unique
      }

      // Firebase signup
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifies email before adding user to database
      User? user = userCredential.user; // Auth user object contains the user UID, email, and verification status.
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Track the time when email verification starts
        final DateTime startTime = DateTime.now();
        bool isVerified = false;

        // Wait for the user to verify email, or timeout after 30 seconds
        while (!isVerified && DateTime.now().difference(startTime).inSeconds < 30) {
          await Future.delayed(Duration(seconds: 5)); // Wait 5 seconds before checking again
          if (user != null) {await user.reload();} // Reload the user to check for updated verification status
          user = _auth.currentUser; //latest user object
          if (user != null) {isVerified = user.emailVerified;} // Check email verification status
        }

        // If email is verified, navigate to the next page
        if (isVerified) {
          if (context.mounted) {
            // Add user to Firestore after verification
            await addUserToFirestore(name, email);
            // Navigate to choose_pet page after email is verified
            Navigator.pushNamed(context, '/choose_pet');
          }
        } else {
          // Show message if verification failed after 30 seconds
          if (context.mounted) {
            if (user != null) {await user.delete();} // Delete user if email not verified
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email verification took too long. Please try again.')),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _isNameUnique(String name) async {
    // Check Firestore to see if the name already exists
    QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .get();

    // If the result contains any documents, that means the name is already taken
    return result.docs.isEmpty;
  }

  Future<void> addUserToFirestore(String name, String email) async {
    // check if a user is logged in before accessing uid
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid; 
      app_user.User newUser = app_user.User(uid, name, email, "", 0);
      user_pet.Pet newPet = user_pet.Pet("", "", "", "", 1, 0);
      await _firestore.collection('users').doc(uid).set({
        'uid': newUser.getuserId,
        'name': newUser.getName,
        'email': newUser.getEmail,
        'bio': newUser.getBio,
        'currentStepcount': newUser.getCurrentStepCount,
        'friends': [],
        'pet': {
          "name": newPet.getPetName,
          "type": newPet.getPetType,
          "description": newPet.getPetDescription,
          "level": newPet.getEvolutionLevel,
          "evoultionBarPoints": newPet.getevolutionBarpoints,
        },
        'logs': [],
        'joinedGroups': [],
      });
    }
  }
}
