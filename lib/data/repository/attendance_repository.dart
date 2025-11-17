import 'package:dartz/dartz.dart';

import '../../models/device_binding.dart';
import '../../models/employee.dart';
import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/attendance_rest.dart';

class AttendanceRepository {
  final AttendanceRest attendanceRest;

  AttendanceRepository({required this.attendanceRest});

  Future<Either<CustomException, String>> attendanceLog({
    required String employeeId,
    required String deviceId,
    required String attendanceType,
    required String address,
    required String entryDate,
    required double latitude,
    required double longitude,
  }) async {
    return attendanceRest.attendanceLog(
      employeeId: employeeId,
      deviceId: deviceId,
      attendanceType: attendanceType,
      address: address,
      latitude: latitude,
      longitude: longitude, 
      entryDate:entryDate,
    );
  }

  Future<Either<CustomException, String>> registerDevice({
    required String employeeId,
    required String deviceId,
    required bool isSales,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    return attendanceRest.registerDevice(
      employeeId: employeeId,
      deviceId: deviceId,
      isSales: isSales,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  Future<Either<CustomException, List<Employee>>> searchEmployee({
    required String query,
  }) async {
    return attendanceRest.searchEmployee(query: query);
  }

  Future<Either<CustomException, List<DeviceBinding>>> getDeviceBindings({
    required String deviceId,
    required String idEmployee,
  }) async {
    return attendanceRest.getDeviceBindings(deviceId: deviceId, idEmployee: idEmployee);
  }

  Future<Either<CustomException, String>> deleteDeviceBinding({
    required String employeeId,
    required String deviceId,
  }) async {
    return attendanceRest.deleteDeviceBinding(
      employeeId: employeeId,
      deviceId: deviceId,
    );
  }
}
