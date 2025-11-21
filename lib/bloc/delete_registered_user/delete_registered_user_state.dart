import 'package:equatable/equatable.dart';
import 'package:viva_attendance/models/device_registered.dart';
// import '../../model/registered_face.dart';

abstract class DeviceRegisteredState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeviceRegisteredInitial extends DeviceRegisteredState {}

class DeviceRegisteredLoading extends DeviceRegisteredState {}

class DeviceRegisteredLoaded extends DeviceRegisteredState {
  final List<RegisteredFace> faces;

  DeviceRegisteredLoaded(this.faces);

  @override
  List<Object?> get props => [faces];
}

class DeviceRegisteredError extends DeviceRegisteredState {
  final String message;

  DeviceRegisteredError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteRegisteredSuccess extends DeviceRegisteredState {
  final String message;

  DeleteRegisteredSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
