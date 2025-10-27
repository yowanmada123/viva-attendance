part of 'attendance_bloc.dart';

class AttendanceState {
  final CameraController? cameraController;
  final String? detectedName;
  final String date;
  final String time;
  final String? errorMessage;
  final bool isDetecting;
  final bool success;
  final bool isLoading;

  AttendanceState({
    this.cameraController,
    this.detectedName,
    this.date = "",
    this.time = "",
    this.errorMessage,
    this.isDetecting = false,
    this.success = false,
    this.isLoading = false,
  });

  AttendanceState copyWith({
    CameraController? cameraController,
    String? detectedName,
    String? date,
    String? time,
    String? errorMessage,
    bool? isDetecting,
    bool? success,
    bool? isLoading,
  }) {
    return AttendanceState(
      cameraController: cameraController ?? this.cameraController,
      detectedName: detectedName ?? this.detectedName,
      date: date ?? this.date,
      time: time ?? this.time,
      errorMessage: errorMessage ?? this.errorMessage,
      isDetecting: isDetecting ?? this.isDetecting,
      success: success ?? this.success,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AttendanceInitial extends AttendanceState {}

class AttendanceCameraReady extends AttendanceState {}

class AttendanceDetecting extends AttendanceState {
  AttendanceDetecting({
    required CameraController controller,
  });
}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final String employeeName;

  AttendanceSuccess({
    required this.employeeName,
    required CameraController cameraController,
  });

  List<Object?> get props => [employeeName, cameraController];
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError({
    required this.message,
    required CameraController cameraController,
  });

  List<Object?> get props => [message, cameraController];
}