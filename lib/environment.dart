import 'package:dio/dio.dart';

class Environment {
  static const apiPath = 'https://android.kencana.org/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 10000),
    receiveTimeout: Duration(milliseconds: 10000),
    contentType: 'application/json',
  );
}

class AuthorizationEnvironment {
  static const apiPath = 'https://v3.kencana.org/';
  static BaseOptions dioBaseOptions = BaseOptions(
    baseUrl: apiPath,
    connectTimeout: Duration(milliseconds: 10000),
    receiveTimeout: Duration(milliseconds: 10000),
    contentType: 'application/json',
  );
}
