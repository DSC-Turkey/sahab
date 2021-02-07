import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  Future<String> getToken() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var playerId = status.subscriptionStatus.userId;

    return playerId;
  }
}
