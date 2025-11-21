import 'package:flutter_bloc/flutter_bloc.dart';
// import 'device_registered_event.dart';
// import 'device_registered_state.dart';
// import '../../model/registered_face.dart';
import 'package:face_verification/face_verification.dart';
import 'package:viva_attendance/bloc/delete_registered_user/delete_registered_user_state.dart';
import 'package:viva_attendance/models/device_registered.dart';

import 'delete_registered_user_event.dart';

class DeviceRegisteredBloc
    extends Bloc<DeviceRegisteredEvent, DeviceRegisteredState> {
  DeviceRegisteredBloc() : super(DeviceRegisteredInitial()) {
    on<LoadRegisteredFaces>(_onLoadRegisteredFaces);
    on<DeleteRegisteredFace>(_onDeleteRegisteredFace);
  }

  Future<void> _onLoadRegisteredFaces(
    LoadRegisteredFaces event,
    Emitter<DeviceRegisteredState> emit,
  ) async {
    emit(DeviceRegisteredLoading());

    try {
      final result = await FaceVerification.instance.getAllRegisteredUsers();

      final faces = result.map((id) => RegisteredFace(id: id)).toList();

      emit(DeviceRegisteredLoaded(faces));
    } catch (e) {
      emit(DeviceRegisteredError("Gagal memuat daftar wajah: $e"));
    }
  }

  Future<void> _onDeleteRegisteredFace(
    DeleteRegisteredFace event,
    Emitter<DeviceRegisteredState> emit,
  ) async {
    try {
      await FaceVerification.instance.deleteFaceRecord(
        event.userId,
        "work_id", // FIXED — sesuai register
      );

      emit(DeleteRegisteredSuccess("Berhasil menghapus user ${event.userId}"));
    } catch (e) {
      emit(DeviceRegisteredError("Gagal menghapus: $e"));
    }
  }
}
