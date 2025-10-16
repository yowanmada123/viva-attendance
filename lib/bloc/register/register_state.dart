part of 'register_bloc.dart';

class RegisterState {
  final CameraController? cameraController;
  final String? detectedName;
  final String date;
  final String time;
  final bool isDetecting;

  RegisterState({
    this.cameraController,
    this.detectedName,
    this.date = "",
    this.time = "",
    this.isDetecting = false,
  });

  RegisterState copyWith({
    CameraController? cameraController,
    String? detectedName,
    String? date,
    String? time,
    bool? isDetecting,
  }) {
    return RegisterState(
      cameraController: cameraController ?? this.cameraController,
      detectedName: detectedName,
      date: date ?? this.date,
      time: time ?? this.time,
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }
}
