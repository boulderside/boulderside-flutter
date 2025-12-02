import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';

abstract class AuthRepository {
  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
    required bool autoLogin,
  });

  Future<void> logout();
}
