import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraUtils {
  static Future<bool> ensureCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (await Permission.camera.request().isGranted) return true;

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Akses kamera ditolak permanen. Buka pengaturan untuk mengaktifkan.',
          ),
          action: SnackBarAction(
            label: 'Buka',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akses kamera diperlukan untuk mengambil foto.'),
        backgroundColor: Colors.red,
      ),
    );

    return false;
  }
}
