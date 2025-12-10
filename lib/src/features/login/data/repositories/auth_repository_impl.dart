import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/oauth_login_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/oauth_signup_request.dart';
import 'package:boulderside_flutter/src/features/login/data/services/oauth_login_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/oauth_signup_service.dart';
import 'package:boulderside_flutter/src/features/login/domain/exceptions/user_not_registered_exception.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/social_login_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._tokenStore,
    this._userStore,
    this._oauthLoginService,
    this._oauthSignupService,
  );

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final OAuthLoginService _oauthLoginService;
  final OAuthSignupService _oauthSignupService;

  @override
  Future<SocialLoginResult> loginWithKakao({
    required String identityToken,
  }) async {
    final request = OAuthLoginRequest(
      providerType: 'KAKAO',
      identityToken: identityToken,
    );

    try {
      final response = await _oauthLoginService.login(request);

      await _tokenStore.saveTokens(
        response.accessToken,
        response.refreshToken,
        true,
      );

      final user = User(
        email: 'kakao_${response.userId}@oauth',
        nickname: response.nickname,
        profileImageUrl: response.profileImageUrl,
      );
      await _userStore.saveUser(user);

      return SocialLoginResult(user: user, isNew: response.isNew);
    } on DioException catch (error) {
      if (_isUserNotRegistered(error)) {
        throw const UserNotRegisteredException();
      }
      rethrow;
    }
  }

  @override
  Future<SocialLoginResult> signupWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
    required String nickname,
  }) async {
    final request = OAuthSignupRequest(
      providerType: providerType,
      identityToken: identityToken,
      nickname: nickname,
    );

    final response = await _oauthSignupService.signup(request);

    await _tokenStore.saveTokens(
      response.accessToken,
      response.refreshToken,
      true,
    );

    final user = User(
      email: '${providerType.emailPrefix}_${response.userId}@oauth',
      nickname: response.nickname,
      profileImageUrl: response.profileImageUrl,
    );
    await _userStore.saveUser(user);

    return SocialLoginResult(user: user, isNew: response.isNew);
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clearTokens();
    await _userStore.clearUser();
  }
}

bool _isUserNotRegistered(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final code = data['code'];
    if (code is String && code == 'D017') {
      return true;
    }
  }
  return false;
}
