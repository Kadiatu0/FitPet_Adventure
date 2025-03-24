import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:fitpet_adventure/ui/signup_page/signup_page.dart';
import 'package:fitpet_adventure/ui/verify_email_page/verify_email_page.dart';
import 'package:fitpet_adventure/ui/signup_page/signup_viewmodel.dart';
import 'package:fitpet_adventure/ui/verify_email_page/verify_email_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SignupViewModel()),
        ChangeNotifierProvider(create: (context) => VerifyEmailViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitPet Adventure',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Change this to '/' // start at signup page
      routes: {
        '/': (context) => const SignupPage(), // Safe default page
        '/signup': (context) => const SignupPage(),
        '/verify_email': (context) => const VerifyEmailPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
