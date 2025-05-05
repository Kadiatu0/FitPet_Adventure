// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/user.dart' as app_user;
import '../../domain/models/pet.dart' as user_pet;
import '../../routing/routes.dart';

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String name, String email, String password, BuildContext context) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
      }
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      bool isNameUnique = await _isNameUnique(name);
      if (!isNameUnique) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The name is already taken. Please choose another name.')),
          );
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        final DateTime startTime = DateTime.now();

        // TEMP: Automatically allow verified during dev
        bool isVerified = true;

        // For production, use:
        // bool isVerified = false;
        // while (!isVerified && DateTime.now().difference(startTime).inSeconds < 30) {
        //   await Future.delayed(Duration(seconds: 5));
        //   await user.reload();
        //   user = _auth.currentUser;
        //   isVerified = user?.emailVerified ?? false;
        // }

        if (isVerified) {
          if (context.mounted) {
            await addUserToFirestore(name, email);
            context.push(Routes.choosePet);
          }
        } else {
          if (context.mounted) {
            await user.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email verification took too long. Please try again.')),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.message}')),
        );
      }
    } catch (e) {
      print('Unexpected signup error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred. Please try again.')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _isNameUnique(String name) async {
    try {
      QuerySnapshot<Map<String, dynamic>> result = await _firestore
          .collection('users')
          .where('name', isEqualTo: name)
          .get();
      return result.docs.isEmpty;
    } catch (e) {
      print('Error checking name uniqueness: $e');
      return false;
    }
  }

  Future<void> addUserToFirestore(String name, String email) async {
    try {
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
          'friendRequests': [],
          'sentRequests': [],
        });
      }
    } catch (e) {
      print('Failed to add user to Firestore: $e');
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
    }
  }
}
