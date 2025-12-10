import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';

class OAuthSignupRequest {
  const OAuthSignupRequest({
    required this.providerType,
    required this.identityToken,
    required this.nickname,
  });

  final AuthProviderType providerType;
  final String identityToken;
  final String nickname;

  Map<String, dynamic> toJson() {
    return {
      'providerType': providerType.serverValue,
      'identityToken': identityToken,
      'nickname': nickname,
    };
  }
}
