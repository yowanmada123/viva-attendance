import 'dart:async';
import 'dart:convert';
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

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  late FaceDetector _faceDetector;
  Timer? _timer;

  AttendanceBloc() : super(AttendanceState()) {
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
    Emitter<AttendanceState> emit,
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
    Emitter<AttendanceState> emit,
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
        final filePath = await _saveCameraImage(state.cameraController!);
        final matchId = await FaceVerification.instance.verifyFromImagePath(
          imagePath: filePath,
          threshold: 0.70,
        );

        if (matchId != null) {
          emit(state.copyWith(detectedName: user['name1']));
        } else {
          emit(state.copyWith(detectedName: null));
        }
      } else {
        emit(state.copyWith(detectedName: null));
      }
    } catch (e) {
      debugPrint("Face detection error: $e");
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

  void _onUpdateDateTime(UpdateDateTime event, Emitter<AttendanceState> emit) {
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
