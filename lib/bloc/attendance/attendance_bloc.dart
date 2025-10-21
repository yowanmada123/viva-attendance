import 'dart:async';
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
import 'package:geocoding/geocoding.dart';
import 'package:viva_attendance/data/repository/attendance_repository.dart';

import '../../../utils/strict_location.dart';
import '../../utils/device_utils.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository attendanceRepository;
  late FaceDetector _faceDetector;
  Timer? _timer;

  AttendanceBloc({required this.attendanceRepository})
    : super(AttendanceState()) {
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
    if (state.success == true) return;
    if (state.isDetecting == true) return;
    emit(state.copyWith(isDetecting: true));

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

      final matchId = await FaceVerification.instance.verifyFromImagePath(
        imagePath: filePath,
        threshold: 0.70,
      );

      if (matchId != null) {
        final position = await StrictLocation.getCurrentPosition();

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final address =
            placemarks.isNotEmpty
                ? "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}"
                : "Address not found";

        // For formatting purposes
        final name = matchId.split('-')[1];
        final idEmployee = matchId.split('-')[0];

        final deviceId = await DeviceUtils.getDeviceId();

        log(
          "Attendance: Device ID: $deviceId, ID Employee: $idEmployee, Name: $name, Address: $address, Latitude: ${position.latitude}, Longitude: ${position.longitude}",
        );

        log("Fetch to API");
        await attendanceRepository.attendanceLog(
          deviceId: deviceId,
          employeeId: idEmployee,
          attendanceType: "IN",
          employeeName: name,
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        emit(state.copyWith(detectedName: matchId, success: true));
      } else {
        emit(state.copyWith(detectedName: null));
      }
    } catch (e) {
      debugPrint(e.toString());
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
}
