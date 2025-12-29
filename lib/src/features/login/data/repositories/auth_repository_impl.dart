import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/notifications/fcm_token_service.dart';
import 'package:boulderside_flutter/src/core/notifications/stores/notification_store.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/models/update_consent_response.dart';
import 'package:boulderside_flutter/src/core/user/models/user_meta.dart';
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
    this._dio,
    this._tokenStore,
    this._userStore,
    this._fcmTokenService,
    this._notificationStore,
    this._oauthLoginService,
    this._oauthSignupService,
  );

  final Dio _dio;
  final TokenStore _tokenStore;
  final UserStore _userStore;
  final FcmTokenService _fcmTokenService;
  final NotificationStore _notificationStore;
  final OAuthLoginService _oauthLoginService;
  final OAuthSignupService _oauthSignupService;

  @override
  Future<SocialLoginResult> loginWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
  }) async {
    final request = OAuthLoginRequest(
      providerType: providerType.serverValue,
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
        email: '${providerType.emailPrefix}_${response.userId}@oauth',
        nickname: response.nickname,
        profileImageUrl: response.profileImageUrl,
      );
      await _userStore.saveUser(user);
      await NotificationStore.setActiveUserId(response.userId.toString());
      if (!response.isNew) {
        await _fcmTokenService.syncFcmToken();
      }

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
    required bool privacyAgreed,
    required bool serviceTermsAgreed,
    required bool overFourteenAgreed,
    required bool marketingAgreed,
  }) async {
    final request = OAuthSignupRequest(
      providerType: providerType,
      identityToken: identityToken,
      nickname: nickname,
      privacyAgreed: privacyAgreed,
      serviceTermsAgreed: serviceTermsAgreed,
      overFourteenAgreed: overFourteenAgreed,
      marketingAgreed: marketingAgreed,
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
    await NotificationStore.setActiveUserId(response.userId.toString());
    await _fcmTokenService.syncFcmToken();

    return SocialLoginResult(user: user, isNew: response.isNew);
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/users/me/logout');
    } on DioException {
      // 서버 로그아웃 실패해도 로컬 상태는 정리한다.
    }
    await _fcmTokenService.disable();
    await _notificationStore.clear();
    await _tokenStore.clearTokens();
    await _userStore.clearUser();
  }

  @override
  Future<UserMeta> fetchUserMeta() async {
    final response = await _dio.get('/users/me/meta');
    final payload = response.data;
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    final metaJson = data is Map<String, dynamic> ? data : <String, dynamic>{};
    final meta = UserMeta.fromJson(metaJson);

    final currentUser = _userStore.user;
    if (currentUser != null) {
      await _userStore.updateUser(
        currentUser.copyWith(marketingConsentAgreed: meta.marketingAgreed),
      );
    }

    return meta;
  }

  @override
  Future<bool> updateMarketingConsent({required bool agreed}) async {
    final response = await _dio.patch(
      '/users/me/consent',
      data: {'consentType': 'MARKETING', 'agreed': agreed},
    );

    final payload = response.data;
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    final responseJson = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};
    final updateResponse = UpdateConsentResponse.fromJson(responseJson);
    final serverAgreed = updateResponse.agreed;

    final currentUser = _userStore.user;
    if (currentUser != null) {
      await _userStore.updateUser(
        currentUser.copyWith(marketingConsentAgreed: serverAgreed),
      );
    }

    return serverAgreed;
  }

  @override
  Future<bool> updatePushConsent({required bool agreed}) async {
    final response = await _dio.patch(
      '/users/me/consent',
      data: {'consentType': 'PUSH', 'agreed': agreed},
    );

    final payload = response.data;
    final data = payload is Map<String, dynamic> ? payload['data'] : null;
    final responseJson = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};
    final updateResponse = UpdateConsentResponse.fromJson(responseJson);
    return updateResponse.agreed;
  }

  @override
  Future<void> withdraw({String? reason}) async {
    await _dio.delete('/users/me', data: {'reason': reason});
    await logout();
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
