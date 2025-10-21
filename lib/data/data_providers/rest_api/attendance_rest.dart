import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../models/errors/custom_exception.dart';
import '../../../../utils/net_utils.dart';

class AttendanceRest {
  Dio http;

  AttendanceRest(this.http);

  Future<Either<CustomException, String>> attendanceLog({
    required String employeeId,
    required String employeeName,
    required String deviceId,
    required String attendanceType,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/transaction/CustomerVisit/getUserData (GET)',
      );

      final payload = {
        "employeeId": employeeId,
        "employeeName": employeeName,
        "deviceId": deviceId,
        "attendance_type": attendanceType,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };

      log("Payload: $payload");

      return Right("Success");

      final response = await http.post(
        "api/viva/transaction/CustomerVisit/getUserData",
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
    required String employeeId,
    required String employeeName,
    required String deviceId,
  }) async {
    try {
      http.options.headers['requiresToken'] = true;
      log(
        'Request to https://v2.kencana.org/api/viva/transaction/CustomerVisit/getUserData (GET)',
      );

      final payload = {
        "employeeId": employeeId,
        "employeeName": employeeName,
        "deviceId": deviceId,
      };

      log("Payload: $payload");

      return Right("Success");

      final response = await http.post(
        "api/viva/transaction/CustomerVisit/getUserData",
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
}
