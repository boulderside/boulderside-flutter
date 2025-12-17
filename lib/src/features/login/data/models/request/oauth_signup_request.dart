import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';

class OAuthSignupRequest {
  const OAuthSignupRequest({
    required this.providerType,
    required this.identityToken,
    required this.nickname,
    required this.privacyAgreed,
    required this.serviceTermsAgreed,
    required this.overFourteenAgreed,
    required this.marketingAgreed,
  });

  final AuthProviderType providerType;
  final String identityToken;
  final String nickname;
  final bool privacyAgreed;
  final bool serviceTermsAgreed;
  final bool overFourteenAgreed;
  final bool marketingAgreed;

  Map<String, dynamic> toJson() {
    return {
      'providerType': providerType.serverValue,
      'identityToken': identityToken,
      'nickname': nickname,
      'privacyAgreed': privacyAgreed,
      'serviceTermsAgreed': serviceTermsAgreed,
      'overFourteenAgreed': overFourteenAgreed,
      'marketingAgreed': marketingAgreed,
    };
  }
}
