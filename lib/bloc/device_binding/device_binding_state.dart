part of 'device_binding_bloc.dart';

abstract class DeviceBindingState {}

class DeviceBindingInitial extends DeviceBindingState {}

class DeviceBindingLoading extends DeviceBindingState {}

class DeviceBindingLoaded extends DeviceBindingState {
  final List<DeviceBinding> faces;
  DeviceBindingLoaded(this.faces);
}

class DeviceBindingError extends DeviceBindingState {
  final String message;
  DeviceBindingError(this.message);
}

class DeleteDeviceBindingSuccess extends DeviceBindingState {
  final String message;
  DeleteDeviceBindingSuccess(this.message);
}
