import 'package:json_annotation/json_annotation.dart';
import 'package:boulderside_flutter/signup/models/enums.dart';

part 'phone_lookup_response.g.dart';

@JsonSerializable()
class PhoneLookupResponse {
  final bool exists;
  final String? nickname;
  final String? phone;
  final UserRole? userRole;
  final UserSex? userSex;
  final Level? userLevel;
  final String? name;

  PhoneLookupResponse({
    required this.exists,
    this.nickname,
    this.phone,
    this.userRole,
    this.userSex,
    this.userLevel,
    this.name,
  });

  factory PhoneLookupResponse.fromJson(Map<String, dynamic> json) =>
      _$PhoneLookupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneLookupResponseToJson(this);
}
