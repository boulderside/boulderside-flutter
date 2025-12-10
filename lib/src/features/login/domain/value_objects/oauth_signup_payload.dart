import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';

class OAuthSignupPayload {
  const OAuthSignupPayload({
    required this.providerType,
    required this.identityToken,
  });

  final AuthProviderType providerType;
  final String identityToken;
}
