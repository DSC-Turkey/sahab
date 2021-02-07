import 'package:sahab/models/account.dart';

class AccountQuery {
  Account account;
  dynamic error;
  int errorType;
  bool isSuccess;

  AccountQuery.success({Account cAccount}) {
    account = cAccount;
    isSuccess = true;
  }
  AccountQuery.failed({dynamic cError, int cErrorType}) {
    error = cError;
    errorType = cErrorType;
    isSuccess = false;
  }
}
