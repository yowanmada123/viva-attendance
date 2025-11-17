
import 'dart:convert';
import 'dart:developer';

import 'package:face_verification/face_verification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_attendance/data/data_providers/shared-preferences/shared_preferences_key.dart';
import 'package:viva_attendance/data/data_providers/shared-preferences/shared_preferences_manager.dart';
import 'package:viva_attendance/data/repository/attendance_repository.dart';
import 'package:viva_attendance/models/device_binding.dart';
import 'package:viva_attendance/utils/device_utils.dart';

import '../../data/data_providers/shared-preferences/shared_preferences_key.dart';
import '../../data/data_providers/shared-preferences/shared_preferences_manager.dart';

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
    
    String? username; 

    final pref = SharedPreferencesManager(key: SharedPreferencesKey.usernameAccessKey);
    
    final data = await pref.read();
    

    if (data != null) {
      final decoded = json.decode(data);
      username = decoded['username'];
    }

    if (username == null) {
      emit(DeviceBindingError("Username tidak ditemukan"));
      return;
    }

    log ('Username: $username');
    
    try {
      final pref = SharedPreferencesManager(key: SharedPreferencesKey.loginRememberKey);
      final data = await pref.read();
      String idEmployee = '';
      if (data != null) {
        final decoded = json.decode(data);
        idEmployee = decoded['username'];

      }

      final res = await attendanceRepository.getDeviceBindings(
        deviceId: await DeviceUtils.getDeviceId(),
        idEmployee: username
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