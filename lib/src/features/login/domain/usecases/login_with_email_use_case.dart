import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  const LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String email,
    required String password,
    required bool autoLogin,
  }) {
    return _repository.loginWithEmail(
      email: email,
      password: password,
      autoLogin: autoLogin,
    );
  }
}
