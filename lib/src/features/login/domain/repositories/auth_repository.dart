import 'package:boulderside_flutter/src/features/login/domain/value_objects/social_login_result.dart';

abstract class AuthRepository {
  Future<SocialLoginResult> loginWithKakao({required String identityToken});

  Future<void> logout();
}
