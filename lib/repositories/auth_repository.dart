import 'package:sahab/models/account_query.dart';
import 'package:sahab/services/firebase_auth_service.dart';
import 'package:sahab/locator.dart';

class AuthRepository {
  final FirebaseAuthService _authRepository =
      locator.get<FirebaseAuthService>();

  Future<AccountQuery> createAccount(
      {String emailAddress, String password}) async {
    return await _authRepository.createAccount(
        email: emailAddress, password: password);
  }

  String getCurrentUserId() {
    return _authRepository.getCurrentUserId();
  }

  Future<bool> signOut() async {
    return await _authRepository.signOut();
  }

  Future<bool> deleteAuth({String email, String password}) async {
    return await _authRepository.deleteAuth(email: email, password: password);
  }

  Future<AccountQuery> signInWithEmailAndPassword(
      {String email, String password}) async {
    return await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
