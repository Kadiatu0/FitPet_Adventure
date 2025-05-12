import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show CollectionReference;
import 'package:intl/intl.dart';

import '../../services/api/model/firebase/firebase_service.dart';
import '../../../domain/models/cosmetic.dart';
import '../../../utils/execute_on_filter.dart';

class FirestoreRepository extends ChangeNotifier {
  FirestoreRepository({required FirebaseService firebaseService})
    : _firebaseService = firebaseService;

  /// Stored in field value 'total_steps'.
  Future<int> get totalSteps async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['currentStepcount'] ?? 0;
  }

  /// Returns a step data map in the following formats based on [filter]:
  /// Daily: {'0-24': num}
  /// Monthly: {'0-31': num}
  /// Yearly: {'0-12': num}
  Future<Map<String, dynamic>> getStepsOnDate(
    String filter,
    DateTime date,
  ) async {
    final formattedDate = _formatDates(filter, date);
    final stepsDoc = _getCollection(filter).doc(formattedDate);
    final snapshot = await stepsDoc.get();
    return snapshot.data() ?? {};
  }

  Future<String> get petName async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['pet']['name'] ?? '';
  }

  Future<void> updatePetName(String name) async {
    await _firebaseService.updateMapValue(
      _firebaseService.userDoc,
      'pet',
      'name',
      name,
    );
  }

  Future<String> get petType async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['pet']['type'] ?? '';
  }

  Future<int> get petEvolutionNum async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['pet']['evolutionBarPoints'] ?? 0;
  }

  /// Synchronously increments values using keys:
  Future<void> incrementSteps(int steps) async {
    await _incrementTotalSteps(steps);
    await _incrementDailySteps(steps);
    await _incrementMonthlySteps(steps);
    await _incrementYearlySteps(steps);
    notifyListeners();
  }

  /// Stored in field value 'session_steps'.
  Future<int> get sessionSteps async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['session_steps'] ?? 0;
  }

  /// Increments field 'session_steps'.
  Future<void> incrementSessionSteps(int steps) async {
    await _firebaseService.increment(
      _firebaseService.userDoc,
      'session_steps',
      steps,
    );
  }

  /// Resets field 'session_steps' to 0.
  Future<void> resetSessionSteps() async {
    await _firebaseService.reset(_firebaseService.userDoc, 'session_steps');
  }

  /// Increments pet field 'evolutionBarPoints'.
  Future<void> incrementEvolution(int amount) async {
    await _firebaseService.incrementMapValue(
      _firebaseService.userDoc,
      'pet',
      'evolutionBarPoints',
      amount,
    );
  }

  /// Saves a [cosmetic] to firestore as a document.
  void saveCosmetic(Cosmetic cosmetic) {
    final doc = _toMap(cosmetic);

    _firebaseService.addDoc(
      _firebaseService.cosmeticsCollection,
      doc,
      cosmetic.uuid,
    );

    notifyListeners();
  }

  /// Deletes a [cosmetic] from firestore.
  void deleteCosmetic(Cosmetic cosmetic) {
    _firebaseService.deleteDoc(
      _firebaseService.cosmeticsCollection,
      cosmetic.uuid,
    );
  }

  /// Deletes all cosmetics in firestore.
  Future<void> deleteAllCosmetics() async {
    await _firebaseService.clearCollection(_firebaseService.cosmeticsCollection);
  }

  /// Load the [List] of cosmetics from firestore as a [Map].
  Future<Map<String, Cosmetic>> loadCosmetics() async {
    final cosmeticsCollection = _firebaseService.cosmeticsCollection;
    final snapshot = await cosmeticsCollection.get();
    final cosmeticMap = <String, Cosmetic>{
      for (final doc in snapshot.docs) doc.data()['uuid']: _fromMap(doc.data()),
    };

    return cosmeticMap;
  }

  final FirebaseService _firebaseService;

  /// Formats a [date] to ISO 8601 based on [filter].
  String _formatDates(String filter, DateTime date) {
    return executeOnFilter(
      filter,
      () => DateFormat('yyyy-MM-dd').format(date),
      () => DateFormat('yyyy-MM').format(date),
      () => DateFormat('yyyy').format(date),
    );
  }

  /// Helper to get collections based on [filter].
  CollectionReference<Map<String, dynamic>> _getCollection(String filter) {
    return executeOnFilter(
      filter,
      () => _firebaseService.dailyCollection,
      () => _firebaseService.monthlyCollection,
      () => _firebaseService.yearlyCollection,
    );
  }

  /// Increments field 'currentStepcount'.
  Future<void> _incrementTotalSteps(int steps) async {
    await _firebaseService.increment(
      _firebaseService.userDoc,
      'currentStepcount',
      steps,
    );
  }

  /// Increments field with the current hour.
  Future<void> _incrementDailySteps(int steps) async {
    // Steps are stored and accessed using the date as the key.
    final currentDate = DateTime.now();
    final dailyFilter = 'Daily';
    final currentDay = _formatDates(dailyFilter, currentDate);
    final dailyDoc = _firebaseService.dailyCollection.doc(currentDay);

    // Increment steps for the current hour.
    await _firebaseService.increment(dailyDoc, '${currentDate.hour}', steps);
  }

  /// Increments field with the current day.
  Future<void> _incrementMonthlySteps(int steps) async {
    // Steps are stored and accessed using the date as the key.
    final currentDate = DateTime.now();
    final monthlyFilter = 'Monthly';
    final currentMonth = _formatDates(monthlyFilter, currentDate);
    final monthlyDoc = _firebaseService.monthlyCollection.doc(currentMonth);

    // Increment steps for the current day.
    await _firebaseService.increment(monthlyDoc, '${currentDate.day}', steps);
  }

  /// Increments field with the current month.
  Future<void> _incrementYearlySteps(int steps) async {
    // Steps are stored and accessed using the date as the key.
    final currentDate = DateTime.now();
    final yearlyFilter = 'Yearly';
    final currentYear = _formatDates(yearlyFilter, currentDate);
    final yearlyDoc = _firebaseService.yearlyCollection.doc(currentYear);

    // Increment steps for the current month.
    await _firebaseService.increment(yearlyDoc, '${currentDate.month}', steps);
  }

  /// Converts a [cosmetic] to a [Map] for saving to firestore.
  Map<String, dynamic> _toMap(Cosmetic cosmetic) {
    return {
      'imagePath': cosmetic.imagePath,
      'uuid': cosmetic.uuid,
      'width': cosmetic.width,
      'height': cosmetic.height,
      'dx': cosmetic.position.dx,
      'dy': cosmetic.position.dy,
      'scale': cosmetic.scale,
      'rotation': cosmetic.rotation,
      'isFlipped': cosmetic.isFlipped,
      'petWidth': cosmetic.petWidth,
      'petHeight': cosmetic.petHeight,
    };
  }

  /// Converts a [map] from firestore to a [Cosmetic].
  Cosmetic _fromMap(Map<String, dynamic> map) {
    return Cosmetic(
      imagePath: map['imagePath'],
      uuid: map['uuid'],
      width: map['width'],
      height: map['height'],
      position: Offset(map['dx'], map['dy']),
      scale: map['scale'],
      rotation: map['rotation'],
      isFlipped: map['isFlipped'],
      petWidth: map['petWidth'],
      petHeight: map['petHeight'],
    );
  }
}
