import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahab/locator.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/models/account_query.dart';
import 'package:sahab/services/firestore_db_service.dart';

class DatabaseRepository {
  final FirestoreDbService _databaseService = locator.get<FirestoreDbService>();

  Future<AccountQuery> createUser(
      {String userId, String email, String password}) async {
    return await _databaseService.createUser(
        userId: userId, email: email, password: password);
  }

  Future<AccountQuery> signIntoDatabase(
      {String userId, String password}) async {
    return await _databaseService.signIntoDatabase(
        userId: userId, password: password);
  }

  void listenAccount({String userId, Function(Account) onChanged}) {
    _databaseService.listenAccount(userId: userId, onChanged: onChanged);
  }

  Future<bool> updateAccountInfo(
      {String userId, Map<String, dynamic> latestInfos}) async {
    return await _databaseService.updateAccountInfo(
        userId: userId, latestInfos: latestInfos);
  }

  Future<bool> signOuttoDatabase() async {
    return await _databaseService.signOuttoDatabase();
  }

  Future<bool> writeLog({String accountId, String log}) async {
    return await _databaseService.writeLog(accountId: accountId, log: log);
  }

  Future<bool> saveNotificationId(
      {String accountId, String notificationId}) async {
    return await _databaseService.saveNotificationId(
        accountId: accountId, notificationId: notificationId);
  }

  Future<bool> removeNotificationId(
      {String accountId, String notificationId}) async {
    return await _databaseService.removeNotificationId(
        accountId: accountId, notificationId: notificationId);
  }

  Future<bool> updateInformations(
      {String userId,
      String name,
      String age,
      String job,
      String instagram,
      String twitter,
      String linkedin}) async {
    return await _databaseService.updateInformations(
        userId: userId,
        name: name,
        age: age,
        job: job,
        instagram: instagram,
        twitter: twitter,
        linkedin: linkedin);
  }

  Future<bool> updateUsersLastGeoPoint({String userId}) async {
    return await _databaseService.updateUsersLastGeoPoint(userId: userId);
  }

  Future<List<Account>> getNearbyUsers(
      {String userId, GeoPoint geoPoint, int limit = 10}) async {
    return await _databaseService.getNearbyUsers(
        userId: userId, geoPoint: geoPoint, qLimit: limit);
  }
}
