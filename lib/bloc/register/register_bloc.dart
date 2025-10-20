import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
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
    if (state.isDetecting == true) return;
    emit(state.copyWith(isDetecting: true));
    SharedPreferencesManager sharedPref = SharedPreferencesManager(key: 'auth');
    final dataString = await sharedPref.read();
    final Map<String, dynamic> data = json.decode(dataString!);
    final user = data['user'];

    final filePath = await _saveCameraImage(state.cameraController!);

    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return;
      }
      if (faces.length > 1) {
        return;
      }

      final isFaceRegistered = await FaceVerification.instance.isFaceRegistered(
        user['username'],
      );

      if (isFaceRegistered) {
        emit(
          state.copyWith(
            success: false,
            errorMessage: "Face already registered",
            isRegistered: true,
          ),
        );
        return;
      }

      final result = await FaceVerification.instance.registerFromImagePath(
        imagePath: filePath,
        imageId: 'work_id',
        id: user['username'],
        replace: true,
      );

      // If success, result will be a username
      if (result == user['username']) {
        emit(state.copyWith(success: true));
      } else {
        log("Failed to register else");
        emit(
          state.copyWith(success: false, errorMessage: "Failed to register"),
        );
      }
    } catch (e) {
      print(e.toString());
      print("Masuk error nih hahahahahaha");
      emit(state.copyWith(success: false, errorMessage: e.toString()));
    } finally {
      emit(state.copyWith(isDetecting: false));
    }
  }

  Future<String> _saveCameraImage(CameraController controller) async {
    final XFile xfile = await controller.takePicture();
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final File savedImage = await File(xfile.path).copy(filePath);

    return savedImage.path;
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
