import 'package:flutter/material.dart';

class ErrorManagement {
  static String getErrorfromCode({@required int errorCode}) {
    switch (errorCode) {
      case 0:
        return 'undetermined_database_error';
        break;
      case 1:
        return 'email_already_in_use';
        break;
      case 2:
        return 'wrong_password';
        break;
      case 3:
        return 'user_not_found';
        break;
      default:
        return 'unknown_error';
    }
  }
}
