import 'package:pedometer/pedometer.dart';

class LocalDataService {
  Stream<PedestrianStatus> get pedestrianStatusStream =>
      Pedometer.pedestrianStatusStream;

  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;
}
