import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/data/services/login_service.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._loginService, this._tokenStore, this._userStore);

  final LoginService _loginService;
  final TokenStore _tokenStore;
  final UserStore _userStore;

  @override
  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
    required bool autoLogin,
  }) async {
    try {
      final response = await _loginService.login(email, password);
      await _tokenStore.saveTokens(
        response.accessToken,
        response.refreshToken,
        autoLogin,
      );

      final user = User(
        email: response.email,
        nickname: response.nickname,
        profileImageUrl: null,
      );
      await _userStore.saveUser(user);
      return Result.success(user);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clearTokens();
    await _userStore.clearUser();
  }
}
