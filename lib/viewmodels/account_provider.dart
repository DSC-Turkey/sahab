import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahab/locator.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/models/account_query.dart';
import 'package:sahab/repositories/auth_repository.dart';
import 'package:sahab/repositories/database_repository.dart';
import 'package:sahab/services/onesignal_service.dart';

enum AccountState {
  Idle,
  Fetching,
  Updating,
  Creating,
  Logining,
  Registering,
  Logouting
}

class AccountProvider extends ChangeNotifier {
  String currentUserId;
  Account _currentAccount;
  List<Account> allManifacturers = [];
  List<Account> allRetailers = [];
  List<Account> retailerRequests = [];
  bool isSetupped = false;
  final AuthRepository _authRepository = locator.get<AuthRepository>();
  final DatabaseRepository _databaseRepository =
      locator.get<DatabaseRepository>();
  final OneSignalService _notificationService = locator.get<OneSignalService>();

  AccountState _state = AccountState.Idle;

  AccountState get state => _state;

  set state(AccountState cState) {
    _state = cState;
    notifyListeners();
  }

  Account get currentAccount => _currentAccount;

  set currentAccount(Account cAccount) {
    _currentAccount = cAccount;
    notifyListeners();
  }

  AccountProvider() {
    getCurrentUserId();
  }

  void getCurrentUserId() {
    final uid = _authRepository.getCurrentUserId();
    currentUserId = uid;
  }

  Future<AccountQuery> createAccount(
      {String emailAddress, String password}) async {
    state = AccountState.Creating;
    var aQuery = await _authRepository.createAccount(
        emailAddress: emailAddress, password: password);

    if (aQuery.isSuccess) {
      currentUserId = aQuery.account.userId;

      var dQuery = await _databaseRepository.createUser(
          userId: aQuery.account.userId,
          email: emailAddress,
          password: password);

      if (dQuery.isSuccess) {
        state = AccountState.Idle;
        listenCurrentUser();
        return dQuery;
      } else {
        await _authRepository.deleteAuth(
            email: emailAddress, password: password);
        state = AccountState.Idle;
        return AccountQuery.failed(cErrorType: 0);
      }
    }
    state = AccountState.Idle;
    return aQuery;
  }

  Future<AccountQuery> signInWithEmailAndPassword(
      {String email, String password}) async {
    state = AccountState.Logining;
    var aQuery = await _authRepository.signInWithEmailAndPassword(
        email: email, password: password);

    if (aQuery.isSuccess) {
      currentUserId = aQuery.account.userId;

      var dQuery = await _databaseRepository.signIntoDatabase(
          userId: aQuery.account.userId, password: password);

      if (dQuery.isSuccess) {
        state = AccountState.Idle;
        listenCurrentUser();
        return dQuery;
      } else {
        await signOut();
        state = AccountState.Idle;
        return AccountQuery.failed(cErrorType: 0);
      }
    }
    state = AccountState.Idle;
    return aQuery;
  }

  void listenCurrentUser({Function(Account cAccount) complated}) {
    _databaseRepository.listenAccount(
      userId: currentUserId,
      onChanged: (account) {
        if (account != null) {
          currentAccount = account;
          if (!isSetupped) {
            complated(account);
            isSetupped = true;
          }
        }
      },
    );
  }

  Future<bool> signOut() async {
    state = AccountState.Logouting;
    await removeNotificationId();
    await _databaseRepository.signOuttoDatabase();
    var logoutResult = await _authRepository.signOut();
    currentAccount = null;
    currentUserId = null;
    state = AccountState.Idle;
    return logoutResult;
  }

  Future<bool> updateAccountInfo(
      {String userId, Map<String, dynamic> latestInfos}) async {
    state = AccountState.Updating;
    var result = await _databaseRepository.updateAccountInfo(
        userId: userId, latestInfos: latestInfos);
    state = AccountState.Idle;
    return result;
  }

  Future<bool> updateInformations(
      {String userId,
      String name,
      String age,
      String job,
      String instagram,
      String twitter,
      String linkedin}) async {
    state = AccountState.Updating;
    var result = await _databaseRepository.updateInformations(
        userId: userId,
        name: name,
        age: age,
        job: job,
        instagram: instagram,
        twitter: twitter,
        linkedin: linkedin);
    state = AccountState.Idle;
    return result;
  }

  Future<bool> writeLog({String accountId, String log}) async {
    state = AccountState.Fetching;
    var result =
        await _databaseRepository.writeLog(accountId: accountId, log: log);
    state = AccountState.Idle;
    return result;
  }

  Future<bool> saveNotificationId() async {
    state = AccountState.Updating;
    var notificationId = await _notificationService.getToken();
    var result = await _databaseRepository.saveNotificationId(
        accountId: currentUserId, notificationId: notificationId);
    state = AccountState.Idle;
    return result;
  }

  Future<bool> removeNotificationId() async {
    state = AccountState.Updating;
    var notificationId = await _notificationService.getToken();
    var result = await _databaseRepository.removeNotificationId(
        accountId: currentUserId, notificationId: notificationId);
    state = AccountState.Idle;
    return result;
  }

  Future<bool> updateUsersLastGeoPoint({String userId}) async {
    state = AccountState.Updating;
    var result = _databaseRepository.updateUsersLastGeoPoint(userId: userId);
    state = AccountState.Idle;
    return result;
  }

  Future<List<Account>> getNearbyUsers(
      {String userId, GeoPoint geoPoint, int limit = 10}) async {
    state = AccountState.Fetching;
    var aList = _databaseRepository.getNearbyUsers(
        userId: userId, geoPoint: geoPoint, limit: limit);
    state = AccountState.Idle;
    return aList;
  }
}
