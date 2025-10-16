part of 'register_bloc.dart';

abstract class RegisterEvent {}

class InitializeCamera extends RegisterEvent {}

class ProcessCameraImage extends RegisterEvent {
  final CameraImage image;
  ProcessCameraImage(this.image);
}

class UpdateDateTime extends RegisterEvent {}
