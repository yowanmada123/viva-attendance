import 'package:geolocator/geolocator.dart';

class StrictLocation {
  static Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi tidak diberikan.');
    }

    return true;
  }

  static Future<void> checkLocationRequirements() async {
    final granted = await checkAndRequestPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!granted) {
      await Geolocator.openAppSettings();
      throw Exception('Izin lokasi tidak diberikan');
    }

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Layanan lokasi tidak aktif');
    }
  }

  static Future<Position> getCurrentPosition() async {
    await checkLocationRequirements();
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return position;
  }
}
