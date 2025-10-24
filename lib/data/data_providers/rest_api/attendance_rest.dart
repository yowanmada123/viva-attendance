import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';
import '../../../models/employee.dart';

class AttendanceRest {
  Dio http;

  AttendanceRest(this.http);

  Future<Either<CustomException, String>> attendanceLog({
    required String employeeId,
    required String deviceId,
    required String attendanceType,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://android.kencana.org/api/attendance (GET)',
      );

      final payload = {
        "idemployee": employeeId,
        "device_id": deviceId,
        "inout_mode": attendanceType,
        "fp_mach_id": 9999,
        "address": address,
        "lattitude": latitude,
        "longitude": longitude,
      };

      final response = await http.post(
        "api/attendance",
        data: payload,
      );

      if (response.statusCode == 200) {
        return Right("Success");
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, String>> registerDevice({
    required int employeeId,
    required String deviceId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://android.kencana.org/api/userRegister (POST)',
      );

      final payload = {
        "employee_id": "$employeeId",
        "device_id": deviceId,
      };

      final response = await http.post(
        "api/userRegister",
        data: payload,
      );

      if (response.statusCode == 200) {
        return Right("Success");
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, List<Employee>>> searchEmployee({
    required String query,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://android.kencana.org/api/searchUser (GET)',
      );

      final payload = {
        "keyword": query,
      };

      final response = await http.get(
        "api/searchUser",
        data: payload,
      );

      if (response.statusCode == 200) {
        final List<Employee> employees = (response.data['data'] as List)
            .map((e) => Employee.fromMap(e))
            .toList();
        return Right(employees);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      if (e is DioException) {
        return Left(NetUtils.parseDioException(e));
      }
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }
}
