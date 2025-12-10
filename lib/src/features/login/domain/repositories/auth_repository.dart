import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/social_login_result.dart';

abstract class AuthRepository {
  Future<SocialLoginResult> loginWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
  });

  Future<SocialLoginResult> signupWithOAuth({
    required AuthProviderType providerType,
    required String identityToken,
    required String nickname,
  });

  Future<void> logout();
}
