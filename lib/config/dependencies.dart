import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/services/local/local_data_service.dart';
import '../data/services/api/model/firebase/firebase_service.dart';
import '../data/repositories/pedometer/pedometer_repository.dart';
import '../data/repositories/firebase/firestore_repository.dart';

List<SingleChildWidget> get providers {
  return [
    Provider.value(value: LocalDataService()),
    Provider(create: (context) => FirebaseService()),
    Provider(
      create:
          (context) => PedometerRepository(localDataService: context.read()),
    ),
    ChangeNotifierProvider(
      create: (context) => FirestoreRepository(firebaseService: context.read()),
    ),
  ];
}
