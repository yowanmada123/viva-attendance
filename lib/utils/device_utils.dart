import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Mengembalikan unique device ID berdasarkan platform
  static Future<String> getDeviceId() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfoPlugin.webBrowserInfo;
        // Kombinasi vendor + userAgent agar cukup unik di web
        return '${webInfo.vendor ?? "unknown"}-${webInfo.userAgent ?? "unknown"}-${webInfo.hardwareConcurrency ?? "0"}';
      }

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        // Android ID bisa dianggap unik (berbeda tiap device)
        return androidInfo.id;
      }

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        // identifierForVendor: ID unik per app vendor (berbeda jika app dihapus dan diinstall ulang)
        return iosInfo.identifierForVendor ?? "unknown_ios_id";
      }

      if (Platform.isWindows) {
        final winInfo = await _deviceInfoPlugin.windowsInfo;
        return winInfo.deviceId;
      }

      if (Platform.isMacOS) {
        final macInfo = await _deviceInfoPlugin.macOsInfo;
        return macInfo.systemGUID ?? "unknown_macos_guid";
      }

      if (Platform.isLinux) {
        final linuxInfo = await _deviceInfoPlugin.linuxInfo;
        return linuxInfo.machineId ?? "unknown_linux_id";
      }

      return "unsupported_platform";
    } catch (e) {
      debugPrint("Error getting device ID: $e");
      return "error_${e.toString()}";
    }
  }
}
