part of 'register_bloc.dart';

abstract class RegisterEvent {}

class RegisterContext {
  final Employee employee;
  final bool isSales;
  final double? latitude;
  final double? longitude;
  final String? address;

  RegisterContext({
    required this.employee,
    this.isSales = false,
    this.latitude,
    this.longitude,
    this.address,
  });
}

class InitializeCamera extends RegisterEvent {
  final RegisterContext context;
  InitializeCamera(this.context);
}

class ProcessCameraImage extends RegisterEvent {
  final CameraImage image;
  final RegisterContext context;
  ProcessCameraImage(this.image, this.context);
}

class UpdateDateTime extends RegisterEvent {}
