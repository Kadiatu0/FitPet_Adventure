// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user.dart' as app_user; // alias to avoid conflict 
import '../../domain/models/pet.dart' as user_pet; // alias to avoid conflict
import 'package:firebase_auth/firebase_auth.dart';


class ChoosePetViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  List<user_pet.Pet> _pets = [];

  List<user_pet.Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all pets from Firestore
  Future<void> fetchPets() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore.collection('Pet').get();
      _pets = snapshot.docs.map((doc) {
        return user_pet.Pet(
          doc.id,
          doc['name'] ?? 'unknown pet name',
          // doc['id'] ?? '',
          doc['description'] ?? '',
          doc['type'] ?? 'unknown',
          1, //default evoultion level 
          0, //default evoultion points
        );
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserPet(user_pet.Pet selectedPet) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;

        // Update the user's pet in Firestore with correct mapping
        await _firestore.collection('users').doc(uid).update({
          'pet': {
            "description": selectedPet.getPetDescription,  // Correctly saving description
            "evolutionBarPoints": 0,  // Default evolution points
            "level": 1,  // Default level
            "name": selectedPet.getPetName,  // Correctly saving name
            "type": selectedPet.getPetType,  // Correctly saving type
          }
        });

        // Notify listeners after updating
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error updating pet: ${e.toString()}";
      notifyListeners();
    }
  }
}
