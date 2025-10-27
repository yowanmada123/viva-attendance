part of 'register_bloc.dart';

class RegisterState {
  final CameraController? cameraController;
  final String? detectedName;
  final String date;
  final String time;
  final bool isDetecting;
  final bool isLoading;
  final bool? success;
  final String? errorMessage;
  final bool isRegistered;

  RegisterState({
    this.cameraController,
    this.detectedName,
    this.date = "",
    this.time = "",
    this.isDetecting = false,
    this.isLoading = false,
    this.success,
    this.errorMessage,
    this.isRegistered = false,
  });

  RegisterState copyWith({
    CameraController? cameraController,
    String? detectedName,
    String? date,
    String? time,
    bool? isDetecting,
    bool? isLoading,
    bool? success,
    String? errorMessage,
    bool? isRegistered,
  }) {
    return RegisterState(
      cameraController: cameraController ?? this.cameraController,
      detectedName: detectedName,
      date: date ?? this.date,
      time: time ?? this.time,
      isDetecting: isDetecting ?? this.isDetecting,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
