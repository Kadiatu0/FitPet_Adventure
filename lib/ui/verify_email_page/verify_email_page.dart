import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'verify_email_viewmodel.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  VerifyEmailPageState createState() => VerifyEmailPageState();
}

class VerifyEmailPageState extends State<VerifyEmailPage> {
  late Timer _timer;
  late Timer _timeoutTimer;
  final int timeoutSeconds = 60; // Timeout for email verification

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<VerifyEmailViewModel>(context, listen: false);

    //Auto-check email verification every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool verified = await viewModel.checkEmailVerification();
      if (verified) {
        _timer.cancel(); // Stop checking once verified
        _timeoutTimer.cancel(); //Stop timeout timer
        if (mounted) {
          Navigator.pop(context); // Go back to previous page
        }
      }
    });

    //If email not verified within timeout, go back
    _timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      _timer.cancel();
      if (mounted) {
        Navigator.pop(context); //Go back to previous page
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timeoutTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<VerifyEmailViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("A verification email has been sent."),
            const Text("Click the link in your email and return to the app."),
            const SizedBox(height: 10),
            if (viewModel.isLoading) const CircularProgressIndicator(), // ✅ Show loader while checking
            if (viewModel.errorMessage != null)
              Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      await viewModel.checkEmailVerification();
                    },
              child: const Text('Check Verification Status'),
            ),
          ],
        ),
      ),
    );
  }
}
