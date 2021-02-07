import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;

class CommonApiService {
  Future<String> getIpAddress() async {
    var response = await http.get('http://api.ipify.org/');
    return response.body;
  }

  Future<String> getOS() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      return ('Android $release (SDK $sdkInt)');
    }
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      return '$systemName $version';
    }
    return 'Unknown OS';
  }

  Future<String> getBrand() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var manufacturer = androidInfo.manufacturer;
      return manufacturer;
    }
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var name = iosInfo.name;
      return name;
    }
    return 'Unknown Brand';
  }

  Future<String> getModel() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var model = androidInfo.model;
      return model;
    }
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var model = iosInfo.model;
      return model;
    }
    return 'Unknown Model';
  }
}
