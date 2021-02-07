import 'package:get_it/get_it.dart';
import 'package:sahab/repositories/auth_repository.dart';
import 'package:sahab/repositories/database_repository.dart';
import 'package:sahab/services/common_api_service.dart';
import 'package:sahab/services/firebase_auth_service.dart';
import 'package:sahab/services/firestore_db_service.dart';
import 'package:sahab/services/onesignal_service.dart';

GetIt locator = GetIt.I;

void setupLocator() async {
  locator.registerLazySingleton(() => AuthRepository());
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => DatabaseRepository());
  locator.registerLazySingleton(() => FirestoreDbService());
  //locator.registerLazySingleton(() => StorageRepository());
  //locator.registerLazySingleton(() => FirebaseStorageService());
  locator.registerLazySingleton(() => CommonApiService());
  //locator.registerLazySingleton(() => NetworkService());
  locator.registerLazySingleton(() => OneSignalService());
}
