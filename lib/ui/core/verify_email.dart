import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkEmailVerification(FirebaseAuth auth) async {
  try {
    User? user = auth.currentUser; // Get the current user
    if (user != null) {
      await user.reload(); // Refresh user data to get the latest info
      return user.emailVerified; // Return email verification status
    }
    return false; // Return false if no user is found
  } catch (e) {
    return false; // Return false in case of error
  }
}