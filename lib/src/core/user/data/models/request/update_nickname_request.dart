import 'package:json_annotation/json_annotation.dart';

part 'update_nickname_request.g.dart';

@JsonSerializable()
class UpdateNicknameRequest {
  UpdateNicknameRequest({required this.nickname});

  factory UpdateNicknameRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateNicknameRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateNicknameRequestToJson(this);

  final String nickname;
}
