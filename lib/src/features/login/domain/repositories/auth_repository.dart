import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/social_login_result.dart';
import 'package:boulderside_flutter/src/core/user/models/user_meta.dart';

abstract class AuthRepository {
  Future<SocialLoginResult> loginWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
  });

  Future<SocialLoginResult> signupWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
    required String nickname,
    required bool privacyAgreed,
    required bool serviceTermsAgreed,
    required bool overFourteenAgreed,
    required bool marketingAgreed,
  });

  Future<void> logout();

  Future<void> withdraw({String? reason});

  Future<UserMeta> fetchUserMeta();

  Future<bool> updateMarketingConsent({required bool agreed});

  Future<bool> updatePushConsent({required bool agreed});
}
