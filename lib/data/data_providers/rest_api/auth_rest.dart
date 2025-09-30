import 'dart:developer';

import 'package:viva_attendance/models/auth.dart';
import 'package:viva_attendance/models/errors/custom_exception.dart';
import 'package:viva_attendance/utils/net_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRest {
  final Dio http;

  AuthRest(this.http);

  Future<Either<CustomException, Auth>> login({
    required String username,
    required String password,
  }) async {
    try {
      final body = {
        'username': username,
        'password': password,
      };
      log('Request to https://v2.kencana.org/api/login (POST)');
      final response = await http.post('api/login', data: body);
      if (response.statusCode == 200) {
        final body = response.data;
        final auth = Auth.fromMap(body['data']);
        return Right(auth);
      } else {
        return Left(NetUtils.parseErrorResponse(response: response.data));
      }
    } on DioException catch (e) {
      return Left(NetUtils.parseDioException(e));
    } on Exception catch (e) {
      return Future.value(Left(CustomException(message: e.toString())));
    } catch (e) {
      return Left(CustomException(message: e.toString()));
    }
  }

  Future<Either<CustomException, void>> logout() async {
    try {
      log('Request to https://v2.kencana.org/api/logout (GET))');
      final response = await http.get('api/logout');
      if (response.statusCode == 200) {
        return const Right(null);
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
