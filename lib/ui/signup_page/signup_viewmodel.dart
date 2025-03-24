import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user.dart' as app_user; // alias to avoid conflict 
import '../../domain/models/pet.dart' as user_pet; // alias to avoid conflict 

class SignupViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance; //for authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //for database

  bool _isLoading = false; //check if process running
  String? _errorMessage; //stores error messages

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String name, String email, String password, BuildContext context) async {
    try {
      _isLoading = true; //indicates signup has started
      _errorMessage = null;
      notifyListeners(); //notifies view/

      // Firebase signup
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      //verifies email before adding user to databse
      User? user = userCredential.user; //auth user object contain the user uid, email, and verification status.
      if (user != null) {
        // redirect user to email verification page
        //check page is mounted first
        if (context.mounted){
          Navigator.pushNamed(context, '/verify_email'); 
          // Add user to Firestore only after verification
          await addUserToFirestore(name, email);
        } 
        else{return;}
        
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUserToFirestore(String name, String email) async {
    // check if a user is logged in before accessing uid
    User? user = _auth.currentUser;
    if( user != null){
      String uid = user.uid; // now safe to use
      app_user.User newUser = app_user.User(uid, name, email, "", 0);
      user_pet.Pet newPet = user_pet.Pet(0, "", "", "", 1, 0);
      await _firestore.collection('users').doc(uid).set({
        'uid': newUser.getuserId,
        'name': newUser.getName,
        'email': newUser.getEmail,
        'bio': newUser.getBio,
        'currentStepcount': newUser.getCurrentStepCount,
        'friends': [],
        'pet': {
          "name" : newPet.getPetName,
          "type" : newPet.getPetType,
          "description" : newPet.getPetDescription,
          "level" : newPet.getEvolutionLevel,
          "evoultionBarPoints" : newPet.getevolutionBarpoints,
        },
        'logs': [],
        'joinedGroups': [],
      });
    }
  }
}

