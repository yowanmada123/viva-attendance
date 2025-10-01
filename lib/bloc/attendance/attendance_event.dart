part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

class InitializeCamera extends AttendanceEvent {}

class ProcessCameraImage extends AttendanceEvent {
  final CameraImage image;
  ProcessCameraImage(this.image);
}

class UpdateDateTime extends AttendanceEvent {}
