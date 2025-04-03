import '../../services/local/local_data_service.dart';

class PedometerRepository {
  PedometerRepository({required LocalDataService localDataService})
    : _localDataService = localDataService;

  Stream get stepCountStream => _localDataService.stepCountStream;

  final LocalDataService _localDataService;
}
