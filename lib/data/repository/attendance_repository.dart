import 'package:dartz/dartz.dart';

import '../../models/employee.dart';
import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/attendance_rest.dart';

class AttendanceRepository {
  final AttendanceRest attendanceRest;

  AttendanceRepository({required this.attendanceRest});

  Future<Either<CustomException, String>> attendanceLog({
    required String employeeId,
    required String employeeName,
    required String deviceId,
    required String attendanceType,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    return attendanceRest.attendanceLog(
      employeeId: employeeId,
      employeeName: employeeName,
      deviceId: deviceId,
      attendanceType: attendanceType,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<Either<CustomException, String>> registerDevice({
    required String employeeId,
    required String employeeName,
    required String deviceId,
  }) async {
    return attendanceRest.registerDevice(
      employeeId: employeeId,
      employeeName: employeeName,
      deviceId: deviceId,
    );
  }

  Future<Either<CustomException, List<Employee>>> searchEmployee({
    required String query,
  }) async {
    return attendanceRest.searchEmployee(query: query);
  }
}
