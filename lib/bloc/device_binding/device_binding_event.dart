part of 'device_binding_bloc.dart';

abstract class DeviceBindingEvent {}

class LoadRegisteredFaces extends DeviceBindingEvent {}
class DeleteRegisteredFace extends DeviceBindingEvent {
  final String employeeId;
  final String employeeName;
  DeleteRegisteredFace(this.employeeId, this.employeeName);
}