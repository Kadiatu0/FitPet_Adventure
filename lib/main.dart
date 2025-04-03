import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;

import '../firebase_options.dart';
import 'config/dependencies.dart';
import 'routing/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: providers, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router(context.read()));
  }
}

/*
Services and repositories are in config/dependencies.dart
Viewmodel instantiation is in routing/router.dart
Routes are in routing/routes.dart
*/
