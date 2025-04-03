import '../../../data/repositories/firebase/firestore_repository.dart';

/// Temporary, replace with auth repository later.
class LoginViewModel {
  LoginViewModel({required FirestoreRepository firestoreRepository})
    : _firestoreRepository = firestoreRepository;

  Future<void> loginWithTestAccount() =>
      _firestoreRepository.loginWithTestAccount();

  final FirestoreRepository _firestoreRepository;
}
