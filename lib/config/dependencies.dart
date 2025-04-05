import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/services/local/local_data_service.dart';
import '../data/services/api/model/firebase/firebase_service.dart';
import '../data/repositories/pedometer/pedometer_repository.dart';
import '../data/repositories/firebase/firestore_repository.dart';

import '../ui/signup_page/signup_viewmodel.dart';
import '../ui/rest_password/reset_password_viewmodel.dart';
import '../ui/login_page/login_viemodel.dart';
import '../ui/choose_pet_page/choose_pet_viewmodel.dart';

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
    ChangeNotifierProvider(create: (context) => SignupViewModel()),
    ChangeNotifierProvider(create: (context) => ResetPasswordViewModel()),
    ChangeNotifierProvider(create: (context) => LoginViewModel()),
    ChangeNotifierProvider(create: (context) => ChoosePetViewModel()),
  ];
}
