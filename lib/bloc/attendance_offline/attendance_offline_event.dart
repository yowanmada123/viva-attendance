// part of 'attendance_offline_bloc.dart';

// sealed class AttendanceOfflineEvent extends Equatable {
//   const AttendanceOfflineEvent();

//   @override
//   List<Object> get props => [];
// }

import 'package:equatable/equatable.dart';

abstract class AttendanceOfflineEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOfflineAttendance extends AttendanceOfflineEvent {}

class UploadOfflineAttendance extends AttendanceOfflineEvent {}
