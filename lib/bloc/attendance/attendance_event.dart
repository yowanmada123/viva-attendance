part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

class InitializeCamera extends AttendanceEvent {
  final String attendanceType;
  InitializeCamera({required this.attendanceType});
}

class ProcessCameraImage extends AttendanceEvent {
  final CameraImage image;
  final String attendanceType;
  ProcessCameraImage(this.image, {required this.attendanceType});
}

class UpdateDateTime extends AttendanceEvent {}
