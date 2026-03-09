import 'package:bloc/bloc.dart';
import 'package:viva_attendance/bloc/attendance_offline/attendance_offline_event.dart';
import 'package:viva_attendance/bloc/attendance_offline/attendance_offline_state.dart';
import 'package:viva_attendance/data/data_providers/local_database.dart';
import 'package:viva_attendance/utils/background_sync.dart';

class OfflineAttendanceBloc
    extends Bloc<AttendanceOfflineEvent, AttendanceOfflineState> {
  OfflineAttendanceBloc() : super(const AttendanceOfflineState()) {
    on<LoadOfflineAttendance>(_onLoadLogs);
    on<UploadOfflineAttendance>(_onUploadLogs);
  }

  Future<void> _onLoadLogs(
    LoadOfflineAttendance event,
    Emitter<AttendanceOfflineState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final logs = await LocalDatabase.getPendingLogs();

    emit(state.copyWith(isLoading: false, logs: logs));
  }

  Future<void> _onUploadLogs(
    UploadOfflineAttendance event,
    Emitter<AttendanceOfflineState> emit,
  ) async {
    emit(state.copyWith(isUploading: true));

    // mulai upload background
    BackgroundSync.startSync();

    // beri waktu sync untuk berjalan
    await Future.delayed(const Duration(seconds: 3));

    final updatedLogs = await LocalDatabase.getPendingLogs();

    emit(
      state.copyWith(
        isUploading: false,
        logs: updatedLogs,
        message: "Upload selesai",
      ),
    );
  }
}
