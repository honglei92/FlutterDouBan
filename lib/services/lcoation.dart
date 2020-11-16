import 'package:geolocator/geolocator.dart';
import 'package:doubanapp/services/location.dart';

class Location {
  double latitude;

  double longitude;

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude.abs();
      longitude = position.longitude.abs();
    } catch (e) {
      print(e);
    }
  }
}
