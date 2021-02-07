import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sahab/extensions/geohash_management.dart';
import 'package:sahab/locator.dart';
import 'package:sahab/models/account.dart';
import 'package:sahab/models/account_query.dart';
import 'package:sahab/services/common_api_service.dart';
import 'package:sahab/services/location_service.dart';

import 'package:uuid/uuid.dart';

class FirestoreDbService {
  final FirebaseFirestore _database = FirebaseFirestore.instance;
  final CommonApiService _apiService = locator.get<CommonApiService>();

  StreamSubscription _accountSubscription;

  void _writeErrorMessage(dynamic error) {
    print('Hata : $error');
  }

  Future<AccountQuery> createUser(
      {String userId, String email, String password}) async {
    try {
      var currentAccount =
          Account(userId: userId, emailAddress: email, password: password);

      var currentIp = await _apiService.getIpAddress();

      await _database.runTransaction((transaction) async {
        transaction.set(_database.collection('accounts').doc(userId),
            currentAccount.toMap());
        transaction.update(_database.collection('accounts').doc(userId),
            {'creationDate': FieldValue.serverTimestamp()});
        transaction.set(
            _database
                .collection('accounts')
                .doc(userId)
                .collection('loginRecords')
                .doc(),
            {
              'loginDate': FieldValue.serverTimestamp(),
              'ipAddress': currentIp,
              'deviceOS': await _apiService.getOS(),
              'deviceBrand': await _apiService.getBrand(),
              'deviceModel': await _apiService.getModel()
            });
      });

      return AccountQuery.success(cAccount: currentAccount);
    } catch (e) {
      _writeErrorMessage(e.toString());
      return AccountQuery.failed(cError: e);
    }
  }

  Future<AccountQuery> signIntoDatabase(
      {String userId, String password}) async {
    try {
      var currentIp = await _apiService.getIpAddress();

      await _database.runTransaction((transaction) async {
        transaction.update(_database.collection('accounts').doc(userId),
            {'password': password});
        transaction.set(
            _database
                .collection('accounts')
                .doc(userId)
                .collection('loginRecords')
                .doc(),
            {
              'loginDate': FieldValue.serverTimestamp(),
              'ipAddress': currentIp,
              'deviceOS': await _apiService.getOS(),
              'deviceBrand': await _apiService.getBrand(),
              'deviceModel': await _apiService.getModel()
            });
      });

      return AccountQuery.success();
    } catch (e) {
      _writeErrorMessage(e.toString());
      return AccountQuery.failed(cError: e);
    }
  }

  void listenAccount({String userId, Function(Account) onChanged}) {
    _accountSubscription = _database
        .collection('accounts')
        .doc(userId)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        var cAccount = Account.fromMap(event.data());
        onChanged(cAccount);
      } else {
        onChanged(null);
      }
    });
  }

  Future<bool> signOuttoDatabase() async {
    try {
      await _accountSubscription.cancel();
      return true;
    } catch (e) {
      _writeErrorMessage(e);
      return null;
    }
  }

  Future<bool> updateAccountInfo(
      {String userId, Map<String, dynamic> latestInfos}) async {
    try {
      var uuid = Uuid();
      var tokenId = uuid.v5(Uuid.NAMESPACE_OID, userId);
      latestInfos['tokenId'] = tokenId;
      await _database.collection('accounts').doc(userId).update(latestInfos);
      return true;
    } catch (e) {
      _writeErrorMessage(e);
      return null;
    }
  }

  Future<bool> writeLog({String accountId, String log}) async {
    try {
      var lRef = _database
          .collection('accounts')
          .doc(accountId)
          .collection('logs')
          .doc();

      await lRef.set({'logTime': FieldValue.serverTimestamp(), 'log': log});

      return true;
    } catch (e) {
      _writeErrorMessage(e.toString());
      return null;
    }
  }
  //sentry

  Future<bool> saveNotificationId(
      {String accountId, String notificationId}) async {
    try {
      await _database.runTransaction((transaction) async {
        var aRef = _database.collection('accounts').doc(accountId);
        transaction.update(aRef, {
          'notificationUids': FieldValue.arrayRemove([notificationId])
        });
        transaction.update(aRef, {
          'notificationUids': FieldValue.arrayUnion([notificationId])
        });
      });

      return true;
    } catch (e) {
      _writeErrorMessage(e.toString());
      return null;
    }
  }

  Future<bool> removeNotificationId(
      {String accountId, String notificationId}) async {
    try {
      await _database.runTransaction((transaction) async {
        var aRef = _database.collection('accounts').doc(accountId);
        transaction.update(aRef, {
          'notificationUids': FieldValue.arrayRemove([notificationId])
        });
      });

      return true;
    } catch (e) {
      _writeErrorMessage(e.toString());
      return null;
    }
  }

  Future<bool> updateInformations(
      {String userId,
      String name,
      String age,
      String job,
      String instagram,
      String twitter,
      String linkedin}) async {
    try {
      await _database.collection('accounts').doc(userId).update({
        'nameAndSurname': name,
        'age': age,
        'job': job,
        'instagram': instagram.isNotEmpty ? instagram : null,
        'twitter': twitter.isNotEmpty ? twitter : null,
        'linkedin': linkedin.isNotEmpty ? linkedin : null,
      });

      return true;
    } catch (e) {
      _writeErrorMessage(e.toString());
      return null;
    }
  }

  Future<bool> updateUsersLastGeoPoint({String userId}) async {
    try {
      var service = LocationService();
      var geoPoint = await service.getLocation();

      var geohash =
          encodeGeohash([geoPoint.latitude, geoPoint.longitude], null);

      await _database
          .collection('accounts')
          .doc(userId)
          .update({'geoPoint': geoPoint, 'geoHash': geohash});

      print(geoPoint.latitude);
      print(geoPoint.longitude);

      return true;
    } catch (e) {
      _writeErrorMessage(e.toString());
      return null;
    }
  }

  Future<List<Account>> getNearbyUsers(
      {String userId, GeoPoint geoPoint, int qLimit = 10}) async {
    try {
      QuerySnapshot snapshot;
      var allUsers = <Account>[];
      var atan =
          geohashQueries([geoPoint.latitude, geoPoint.longitude], (5.0 * 1000));

      print(atan.toString());
      for (var location in atan) {
        var currentQuery = _database
            .collection('accounts')
            .where('isDeleted', isNull: true)
            .where('isBanned', isNull: true);

        currentQuery = currentQuery.where('geoHash',
            isGreaterThanOrEqualTo: location[0],
            isLessThanOrEqualTo: location[1]);

        currentQuery = currentQuery.orderBy('geoHash', descending: true);

        if (snapshot != null) {
          var currentSnapshot = await currentQuery.limit(qLimit).get();

          snapshot.docs.addAll(currentSnapshot.docs);
        } else {
          snapshot = await currentQuery.limit(qLimit).get();
        }
      }

      for (var snap in snapshot.docs) {
        allUsers.add(Account.fromMap(snap.data()));
      }

      print(snapshot.docs.length);
      return allUsers;
    } catch (e, t) {
      _writeErrorMessage('${e} - ${t}');
      return null;
    }
  }
}
