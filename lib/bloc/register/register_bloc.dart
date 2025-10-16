import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:face_verification/face_verification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:viva_attendance/data/data_providers/shared-preferences/shared_preferences_manager.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  late FaceDetector _faceDetector;
  Timer? _timer;

  RegisterBloc() : super(RegisterState()) {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        enableContours: true,
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    FaceVerification.instance.init();

    on<InitializeCamera>(_onInitializeCamera);
    on<ProcessCameraImage>(_onProcessCameraImage);
    on<UpdateDateTime>(_onUpdateDateTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(UpdateDateTime());
    });
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<RegisterState> emit,
  ) async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    final controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();

    controller.startImageStream((image) {
      if (!state.isDetecting) {
        add(ProcessCameraImage(image));
      }
    });

    emit(state.copyWith(cameraController: controller));
  }

  Future<void> _onProcessCameraImage(
    ProcessCameraImage event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(isDetecting: true));
    try {
      final inputImage = _cameraImageToInputImage(
        event.image,
        state.cameraController!.description,
      );

      final faces = await _faceDetector.processImage(inputImage);
      SharedPreferencesManager sharedPref = SharedPreferencesManager(
        key: 'auth',
      );
      final dataString = await sharedPref.read();
      final Map<String, dynamic> data = json.decode(dataString!);
      final user = data['user'];

      if (faces.isNotEmpty) {
        log("Face detected for registration");
        // ✅ Simpan frame ke file
        final filePath = await _saveCameraImage(event.image);

        // ✅ Verifikasi wajah pakai FaceVerification
        await FaceVerification.instance.registerFromImagePath(
          imagePath: filePath,
          imageId: 'work_id',
          id: user['id'],
          replace: true,
        );

        log("Face detected for registration successfully");
      } else {
        emit(state.copyWith(detectedName: null));
      }
    } catch (e) {
      debugPrint("Face detection error: $e");
    } finally {
      emit(state.copyWith(isDetecting: false));
    }
  }

  Future<String> _saveCameraImage(CameraImage image) async {
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Konversi YUV ke RGB
    final jpegBytes = await _convertYUV420toJpeg(image);

    // Simpan ke file
    final file = File(filePath);
    await file.writeAsBytes(jpegBytes);

    return filePath;
  }

  Future<Uint8List> _convertYUV420toJpeg(CameraImage image) async {
    final width = image.width;
    final height = image.height;

    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + 1.370705 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128))
            .round()
            .clamp(0, 255);
        int b = (yp + 1.732446 * (up - 128)).round().clamp(0, 255);

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return Uint8List.fromList(img.encodeJpg(rgbImage));
  }

  void _onUpdateDateTime(UpdateDateTime event, Emitter<RegisterState> emit) {
    final now = DateTime.now();
    final date = DateFormat("dd/MM/yyyy EEE").format(now);
    final time = DateFormat("HH:mm:ss").format(now);
    emit(state.copyWith(date: date, time: time));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    state.cameraController?.dispose();
    _faceDetector.close();
    return super.close();
  }

  InputImage _cameraImageToInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final cameraRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final rawFormat = image.format.raw;
    final inputImageFormat =
        (rawFormat == 35) ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: cameraRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}
