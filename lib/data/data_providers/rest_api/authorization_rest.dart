import 'dart:developer';

import 'package:viva_attendance/models/errors/custom_exception.dart';
import 'package:viva_attendance/utils/net_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthorizationRest {
  final Dio http;

  AuthorizationRest(this.http);

  Future<Either<CustomException, Map<String, String>>> getConv() async {
    try {
      http.options.headers['requiresToken'] = true;

      log('Request to https://v2.kencana.org/api/mobile/getEnvConf (POST)');
      final data = {"entity_id": "VIVA"};
      final response = await http.post("api/mobile/getEnvConf", data: data);

      if (response.statusCode == 200) {
        final body = response.data;

        Map<String, String> result = {};

        for (var item in body['data']) {
          result[item['var_id']] = item['var_value'];
        }

        return Right(result);
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
}
