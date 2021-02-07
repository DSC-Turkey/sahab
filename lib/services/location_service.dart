import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<GeoPoint> getLocation() async {
    try {
      await location.requestPermission();

      var userLocation = await location.getLocation();
      var geoPoint = GeoPoint(userLocation.latitude, userLocation.longitude);
      return geoPoint;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
