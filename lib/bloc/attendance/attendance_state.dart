part of 'attendance_bloc.dart';

class AttendanceState {
  final CameraController? cameraController;
  final String? detectedName;
  final String date;
  final String time;
  final bool isDetecting;

  AttendanceState({
    this.cameraController,
    this.detectedName,
    this.date = "",
    this.time = "",
    this.isDetecting = false,
  });

  AttendanceState copyWith({
    CameraController? cameraController,
    String? detectedName,
    String? date,
    String? time,
    bool? isDetecting,
  }) {
    return AttendanceState(
      cameraController: cameraController ?? this.cameraController,
      detectedName: detectedName ?? this.detectedName,
      date: date ?? this.date,
      time: time ?? this.time,
      isDetecting: isDetecting ?? this.isDetecting,
    );
  }
}
