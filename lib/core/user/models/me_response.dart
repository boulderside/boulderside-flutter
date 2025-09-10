import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';

@JsonSerializable()
class MeResponse {
  final String email;
  final String nickname;
  final String profileImageUrl;

  MeResponse({
    required this.email,
    required this.nickname,
    required this.profileImageUrl,
  });

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MeResponseToJson(this);
}
