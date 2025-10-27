import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_verification/face_verification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/repository/attendance_repository.dart';
import '../../models/employee.dart';
import '../../utils/device_utils.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AttendanceRepository attendanceRepository;
  late FaceDetector _faceDetector;
  Timer? _timer;

  RegisterBloc({required this.attendanceRepository}) : super(RegisterState()) {
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
        add(ProcessCameraImage(image, event.employee));
      }
    });

    emit(state.copyWith(cameraController: controller));
  }

  Future<void> _onProcessCameraImage(
    ProcessCameraImage event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.isLoading || state.isDetecting) return;
    emit(state.copyWith(isDetecting: true, isLoading: true));
    final employee = event.employee;
    final employeeId = employee.idemployee;
    final employeeName = employee.name;
    emit(state.copyWith(detectedName: employeeName));

    final keyOnDatabase = "$employeeId-$employeeName";

    final filePath = await _saveCameraImage(state.cameraController!);

    try {
      await state.cameraController!.stopImageStream();
      final inputImage = InputImage.fromFilePath(filePath);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty || faces.length > 1) {
        emit(state.copyWith(isLoading: false, isDetecting: false));
        await state.cameraController!.startImageStream((image) {
          if (!state.isLoading) add(ProcessCameraImage(image, event.employee));
        });
        return;
      }

      final isFaceRegistered = await FaceVerification.instance.isFaceRegistered(
        keyOnDatabase,
      );

      if (isFaceRegistered) {
        emit(
          state.copyWith(
            success: false,
            errorMessage: "Wajah sudah terdaftar",
            isRegistered: true,
            isLoading: false,
            isDetecting: false,
          ),
        );
        await state.cameraController!.startImageStream((image) {
          if (!state.isLoading) add(ProcessCameraImage(image, event.employee));
        });
        return;
      }

      final result = await FaceVerification.instance.registerFromImagePath(
        imagePath: filePath,
        imageId: 'work_id',
        id: keyOnDatabase,
        replace: true,
      );

      // If success, result will be a username
      if (result == keyOnDatabase) {
        final deviceId = await DeviceUtils.getDeviceId();

        await attendanceRepository.registerDevice(
          deviceId: deviceId,
          employeeId: employeeId,
        );

        emit(state.copyWith(success: true, isLoading: false));
      } else {
        emit(
          state.copyWith(success: false, errorMessage: "Failed to register", isLoading: false),
        );
      }
    } catch (e) {
      emit(state.copyWith(success: false, errorMessage: e.toString(), isLoading: false));
    } finally {
      await state.cameraController?.startImageStream((image) {
        if (!state.isLoading) add(ProcessCameraImage(image, event.employee));
      });

      emit(state.copyWith(isDetecting: false, isLoading: false));
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
}
