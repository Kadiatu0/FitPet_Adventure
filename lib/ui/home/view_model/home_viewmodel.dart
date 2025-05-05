import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/repositories/pedometer/pedometer_repository.dart';
import '../../../data/repositories/firebase/firestore_repository.dart';
import '../../../domain/models/cosmetic.dart';
import '../../../utils/execute_on_filter.dart';
import '../../../utils/get_evolution_name.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required PedometerRepository pedometerRepository,
    required FirestoreRepository firestoreRepository,
  }) : _pedometerRepository = pedometerRepository,
       _firestoreRepository = firestoreRepository {
    final stepCountStream = _pedometerRepository.stepCountStream;
    _stepCountSubscription = stepCountStream
        .asyncMap(_onStepCount)
        .listen((_) {});
    _stepCountSubscription.onError(_onStepCountError);
  }

  String get selectedFilter => _selectedFilter;

  int get totalSteps => _totalSteps;
  int get stepGoal => _stepGoal;
  Future<int> get average async => (await _calculateAverage()).toInt();
  Future<int> get best async => await _calculateBest();

  int get petLevel => (totalSteps / 100).toInt();
  Future<String> get petName async => await _firestoreRepository.petName;
  Future<String> get petType async => await _firestoreRepository.petType;
  String get petEvolutionName => getEvolutionName(_petEvolutionNum);

  Future<void> loadSteps() async {
    _totalSteps = await _firestoreRepository.totalSteps;
  }

  Future<void> loadEvolutionNum() async {
    _petEvolutionNum = await _firestoreRepository.petEvolutionNum;
  }

  /// Decrements day, month, or year.
  void previousPeriod() => _updatePeriod(false);

  // Increments day, month, or year.
  void nextPeriod() => _updatePeriod(true);

  Map<String, Cosmetic> get placedCosmetics => _placedCosmetics;

  set selectedFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  /// Used for development.
  void incrementSteps() {
    ++_totalSteps;
    _firestoreRepository.incrementSteps(1);

    // No more evolutions.
    if (_petEvolutionNum == (_totalEvolutionStages - 1)) {
      notifyListeners();
      return;
    }

    for (var i = 1; i < _totalEvolutionStages; ++i) {
      if (totalSteps == (stepGoal * i)) {
        ++_petEvolutionNum;
        _firestoreRepository.incrementEvolution(1);
      }
    }

    notifyListeners();
  }

  String get cycleMenuLabel {
    final day = _selectedDate.day;
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    return executeOnFilter(
      _selectedFilter,
      () => '$day ${_months[month - 1]}',
      () => '${_months[month - 1]} $year',
      () => '$year',
    );
  }

  /// Number of bars to display for bar graph.
  /// Based on hours, days, and months.
  int get barCount {
    final hours = 24;
    final month = _selectedDate.month;
    final year = _selectedDate.year;
    // Calculate the day of the month.
    final days = DateTime(year, month + 1, 0).day;
    final months = 12;

    return executeOnFilter(
      _selectedFilter,
      () => hours,
      () => days,
      () => months,
    );
  }

  /// Sets max to user's best steps.
  /// Sets max to user's total steps if there's no data.
  Future<double> get yMax async {
    final bestSteps = (await best).toDouble();

    // Return totalSteps where there's no data.
    // Prevents visual glitches.
    if (bestSteps == 0) return totalSteps.toDouble();

    return bestSteps;
  }

  /// Determined by hours, days, and months.
  List<int> get xInterval {
    switch (barCount) {
      // Monthly
      case 31:
        return [1, 15, 31];
      case 30:
        return [1, 15, 30];
      case 29:
        return [1, 14, 29];
      case 28:
        return [1, 14, 28];
      // Daily
      case 24:
        return [0, 12, 23];
      // Yearly
      case 12:
        return [1, 6, 12];
      default:
        return [];
    }
  }

  Future<List<BarChartGroupData>> get barGroups async {
    return (await _generateBarGroups());
  }

  Future<void> loadCosmetics() async {
    _placedCosmetics = await _firestoreRepository.loadCosmetics();
  }

  final PedometerRepository _pedometerRepository;
  final FirestoreRepository _firestoreRepository;
  late final StreamSubscription _stepCountSubscription;
  int _totalSteps = 0;
  final int _stepGoal = 10;
  final int _totalEvolutionStages = 3;
  int _petEvolutionNum = 0;
  // Defaults to monthly.
  String _selectedFilter = 'Monthly';
  DateTime _selectedDate = DateTime.now();
  Map<String, Cosmetic> _placedCosmetics = {};

  final _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Future<void> _onStepCount(event) async {
    // Locally stored motion sensor steps.
    int sensorSteps = event.steps;

    // User restarts their phone which resets the motion sensor step counter.
    if (sensorSteps == 0) _firestoreRepository.resetSessionSteps();

    // Increment in database to keep steps in sync.
    while ((await _firestoreRepository.sessionSteps) < sensorSteps) {
      await _firestoreRepository.incrementSessionSteps(1);
      _firestoreRepository.incrementSteps(1);
      notifyListeners();
    }
  }

  void _onStepCountError(error) {
    // Add error handling.
    // _steps = -1;
    notifyListeners();
  }

  Future<double> _calculateAverage() async {
    var total = 0.0;

    final data = await _firestoreRepository.getStepsOnDate(
      _selectedFilter,
      _selectedDate,
    );

    for (var i = 0; i < barCount; ++i) {
      total += (data[i.toString()] ?? 0);
    }

    final average = total / barCount;
    return average;
  }

  Future<int> _calculateBest() async {
    var best = 0;
    final data = await _firestoreRepository.getStepsOnDate(
      _selectedFilter,
      _selectedDate,
    );

    for (var i = 0; i < barCount; ++i) {
      int steps = (data[i.toString()] ?? 0);
      if (best < steps) {
        best = steps;
      }
    }

    return best;
  }

  /// Increment or decrement day, month, or year based on flag [isNext].
  void _updatePeriod(bool isNext) {
    final day = _selectedDate.day;
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    executeOnFilter(
      _selectedFilter,
      () =>
          _selectedDate =
              isNext
                  ? _selectedDate.add(const Duration(days: 1))
                  : _selectedDate.subtract(const Duration(days: 1)),
      () =>
          _selectedDate =
              isNext
                  ? DateTime(year, month + 1, day)
                  : DateTime(year, month - 1, day),
      () =>
          _selectedDate =
              isNext
                  ? DateTime(year + 1, month, day)
                  : DateTime(year - 1, month, day),
    );

    notifyListeners();
  }

  /// Generates the bars for the bar graph.
  Future<List<BarChartGroupData>> _generateBarGroups() async {
    final steps = await _firestoreRepository.getStepsOnDate(
      _selectedFilter,
      _selectedDate,
    );

    if (steps.isEmpty) return [];

    return List.generate(barCount, (index) {
      // Hours are 0-24 while days and months start from 1.
      String key =
          _selectedFilter == 'Daily'
              ? index.toString()
              : (index + 1).toString();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (steps[key])?.toDouble() ?? 0.0,
            color: Colors.orange.shade700,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _stepCountSubscription.cancel();
    super.dispose();
  }
}
