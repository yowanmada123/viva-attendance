import 'package:dartz/dartz.dart';

import '../../models/errors/custom_exception.dart';
import '../data_providers/rest_api/authorization_rest.dart';

class AuthorizationRepository {
  final AuthorizationRest authorizationRest;

  AuthorizationRepository({required this.authorizationRest});

  Future<Either<CustomException, Map<String, String>>> getConv(
  ) async {
    return authorizationRest.getConv();
  }
}
