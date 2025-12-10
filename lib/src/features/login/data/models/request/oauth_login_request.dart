import 'package:json_annotation/json_annotation.dart';

part 'oauth_login_request.g.dart';

@JsonSerializable()
class OAuthLoginRequest {
  OAuthLoginRequest({required this.providerType, required this.identityToken});

  factory OAuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$OAuthLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthLoginRequestToJson(this);

  final String providerType;
  final String identityToken;
}
