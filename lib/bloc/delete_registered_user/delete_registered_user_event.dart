import 'package:equatable/equatable.dart';

abstract class DeviceRegisteredEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRegisteredFaces extends DeviceRegisteredEvent {}

class DeleteRegisteredFace extends DeviceRegisteredEvent {
  final String userId;

  DeleteRegisteredFace(this.userId);

  @override
  List<Object?> get props => [userId];
}
