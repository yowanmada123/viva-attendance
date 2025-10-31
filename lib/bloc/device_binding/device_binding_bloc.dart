
import 'package:face_verification/face_verification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_attendance/data/repository/attendance_repository.dart';
import 'package:viva_attendance/models/device_binding.dart';
import 'package:viva_attendance/utils/device_utils.dart';

part 'device_binding_event.dart';
part 'device_binding_state.dart';

class DeviceBindingBloc extends Bloc<DeviceBindingEvent, DeviceBindingState> {
  final AttendanceRepository attendanceRepository;

  DeviceBindingBloc({required this.attendanceRepository}) : super(DeviceBindingInitial()) {
    on<LoadRegisteredFaces>(_onLoadRegisteredFaces);
    on<DeleteRegisteredFace>(_onDeleteRegisteredFace);
  }

  Future<void> _onLoadRegisteredFaces(
    LoadRegisteredFaces event,
    Emitter<DeviceBindingState> emit,
  ) async {
    emit(DeviceBindingLoading());
    try {
      final res = await attendanceRepository.getDeviceBindings(
        deviceId: await DeviceUtils.getDeviceId(),
      );
      res.fold(
        (error) => emit(
          DeviceBindingError(error.message!),
        ),
        (data) {
          emit(DeviceBindingLoaded(data));
        },
      );
    } catch (e) {
      emit(DeviceBindingError(e.toString()));
    }
  }

  Future<void> _onDeleteRegisteredFace(
    DeleteRegisteredFace event,
    Emitter<DeviceBindingState> emit,
  ) async {
    emit(DeviceBindingLoading());
    try {
      final existingFace = await FaceVerification.instance.getFacesForUser('${event.employeeId}-${event.employeeName}');
      if (existingFace.isNotEmpty) {
        final employeeFace = existingFace.first;
        await FaceVerification.instance.deleteFaceRecord(employeeFace.id, employeeFace.imageId);
      }
      final res = await attendanceRepository.deleteDeviceBinding(
        employeeId: event.employeeId,
        deviceId: await DeviceUtils.getDeviceId(),
      );
      res.fold(
        (error) => emit(
          DeviceBindingError(error.message!),
        ),
        (data) async {
          emit(DeleteDeviceBindingSuccess(data));
        },
      );
    } catch (e) {
      emit(DeviceBindingError(e.toString()));
    }
  }

}