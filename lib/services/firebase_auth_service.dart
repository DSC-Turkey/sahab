import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/models/account_query.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AccountQuery> createAccount({String email, String password}) async {
    try {
      var credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      var cAccount = Account(
          userId: credential.user.uid,
          emailAddress: credential.user.email,
          password: password);

      return AccountQuery.success(cAccount: cAccount);
    } catch (e) {
      print(e.runtimeType);
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return AccountQuery.failed(cErrorType: 1);
        }
      }
      return AccountQuery.failed(cError: e);
    }
  }

  String getCurrentUserId() {
    return _auth.currentUser != null ? _auth.currentUser.uid : null;
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AccountQuery> signInWithEmailAndPassword(
      {String email, String password}) async {
    try {
      var credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      var cAccount = Account(
          userId: credential.user.uid,
          emailAddress: credential.user.email,
          password: password);

      return AccountQuery.success(cAccount: cAccount);
    } catch (e) {
      print(e.runtimeType);
      print(e);
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          return AccountQuery.failed(cErrorType: 2);
        } else if (e.code == 'user-not-found') {
          return AccountQuery.failed(cErrorType: 3);
        } else {
          return AccountQuery.failed(cErrorType: -1);
        }
      }
      return AccountQuery.failed(cError: e);
    }
  }

  Future<AccountQuery> updatePassword(
      {String email, String oldPassword, String newPassword}) async {
    try {
      var credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      await _auth.currentUser.updatePassword(newPassword);
      return AccountQuery.success();
    } catch (e) {
      return AccountQuery.failed(cError: e);
    }
  }

  Future<AccountQuery> updateEmail(
      {String email, String password, String newEmail}) async {
    try {
      var credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      await _auth.currentUser.updateEmail(newEmail);
      return AccountQuery.success();
    } catch (e) {
      return AccountQuery.failed(cError: e);
    }
  }

  Future<bool> deleteAuth({String email, String password}) async {
    try {
      var credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser.reauthenticateWithCredential(credential);
      await _auth.currentUser.delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
