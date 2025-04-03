import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../view_model/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Temp login with test account for development.
    if (kDebugMode) {
      FutureBuilder(
        future: viewModel.loginWithTestAccount(),
        builder: (context, snapshot) => Container(),
      );
    }

    return Scaffold();
  }
}
