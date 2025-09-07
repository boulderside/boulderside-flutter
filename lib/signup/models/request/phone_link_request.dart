import 'package:json_annotation/json_annotation.dart';

part 'phone_link_request.g.dart';

@JsonSerializable()
class PhoneLinkRequest {
  final String phoneNumber;
  final String email;
  final String password;

  PhoneLinkRequest({
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  factory PhoneLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneLinkRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneLinkRequestToJson(this);
}
