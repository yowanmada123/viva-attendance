part of 'register_bloc.dart';

abstract class RegisterEvent {}

class InitializeCamera extends RegisterEvent {
  final Employee employee;
  InitializeCamera({required this.employee});
}

class ProcessCameraImage extends RegisterEvent {
  final CameraImage image;
  final Employee employee;
  ProcessCameraImage(this.image, this.employee);
}

class UpdateDateTime extends RegisterEvent {}
