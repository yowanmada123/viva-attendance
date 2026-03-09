// part of 'attendance_offline_bloc.dart';

// sealed class AttendanceOfflineState extends Equatable {
//   const AttendanceOfflineState();

//   @override
//   List<Object> get props => [];
// }

// final class AttendanceOfflineInitial extends AttendanceOfflineState {}

import 'package:equatable/equatable.dart';
import 'package:viva_attendance/models/attendance_log.dart';
// import '../models/attendance_log.dart';

class AttendanceOfflineState extends Equatable {
  final List<AttendanceLog> logs;
  final bool isLoading;
  final bool isUploading;
  final String message;

  const AttendanceOfflineState({
    this.logs = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.message = '',
  });

  AttendanceOfflineState copyWith({
    List<AttendanceLog>? logs,
    bool? isLoading,
    bool? isUploading,
    String? message,
  }) {
    return AttendanceOfflineState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      message: message ?? '',
    );
  }

  @override
  List<Object?> get props => [logs, isLoading, isUploading, message];
}
