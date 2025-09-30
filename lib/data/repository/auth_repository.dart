import 'package:viva_attendance/data/data_providers/rest_api/auth_rest.dart';
import 'package:viva_attendance/data/data_providers/shared-preferences/shared_preferences_manager.dart';

import 'package:viva_attendance/models/auth.dart';
import 'package:viva_attendance/models/errors/custom_exception.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final AuthRest authRest;
  final SharedPreferencesManager authSharedPref;

  AuthRepository({required this.authRest, required this.authSharedPref});

  Future<Either<CustomException, Auth>> login({
    required String username,
    required String password,
  }) async {
    final res = await authRest.login(
      username: username,
      password: password,
    );
    return res.fold(
      (exception) {
        return Left(exception);
      },
      (auth) {
        authSharedPref.write(auth.toJson());
        return Right(auth);
      },
    );
  }

  Future<Either<CustomException, void>> logout() async {
    final res = await authRest.logout();
    return res.fold(
      (exception) {
        return Left(exception);
      },
      (auth) {
        authSharedPref.clear();
        return Right(null);
      },
    );
  }
}
