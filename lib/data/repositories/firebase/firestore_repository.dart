import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show CollectionReference;
import 'package:intl/intl.dart';

import '../../services/api/model/firebase/firebase_service.dart';
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

  Future<String> get petType async {
    final snapshot = await _firebaseService.userDoc.get();
    return snapshot.data()?['pet']['type'] ?? '';
  }

  /// Synchronously increments four values using keys:
  /// 'total_steps', 'yyyy-mm-dd', 'yyyy-mm', 'yyyy'
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

  /// Save the list of cosmetics to firestore.
  Future<void> saveCosmetics(List<Map<String, dynamic>> cosmeticsData) async {
    // Clear existing cosmetics first.
    await _firebaseService.clearCollection(
      _firebaseService.cosmeticsCollection,
    );

    // Add new cosmetics.
    for (final cosmetic in cosmeticsData) {
      await _firebaseService.batchAdd(
        _firebaseService.cosmeticsCollection,
        cosmetic,
      );
    }

    notifyListeners();
  }

  Future<String> get petSelection async {
    // Pull user pet selection from firestore here.
    return '';
  }

  /// Load the list of cosmetics from firestore.
  Future<List<Map<String, dynamic>>> loadCosmetics() async {
    final cosmeticsCollection = _firebaseService.cosmeticsCollection;
    final snapshot = await cosmeticsCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
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

  /// Increments field 'total_steps'.
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
}
