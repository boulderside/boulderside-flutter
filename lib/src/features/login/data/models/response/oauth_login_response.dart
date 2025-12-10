import 'package:json_annotation/json_annotation.dart';

part 'oauth_login_response.g.dart';

@JsonSerializable()
class OAuthLoginResponse {
  OAuthLoginResponse({
    required this.userId,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
    required this.isNew,
    this.profileImageUrl,
  });

  factory OAuthLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$OAuthLoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthLoginResponseToJson(this);

  final int userId;
  final String nickname;
  final String accessToken;
  final String refreshToken;
  final bool isNew;
  final String? profileImageUrl;
}
