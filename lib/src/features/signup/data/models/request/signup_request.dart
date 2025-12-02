import 'package:json_annotation/json_annotation.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/enums.dart';

part 'signup_request.g.dart';

@JsonSerializable()
class SignupRequest {
  final String nickname;
  final String phone;
  final UserRole userRole;
  final UserSex userSex;
  final Level userLevel;
  final String? name;
  final String email;
  final String password;

  SignupRequest({
    required this.nickname,
    required this.phone,
    required this.userRole,
    required this.userSex,
    required this.userLevel,
    this.name,
    required this.email,
    required this.password,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}
