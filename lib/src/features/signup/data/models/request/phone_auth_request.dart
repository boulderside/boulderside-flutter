import 'package:json_annotation/json_annotation.dart';

part 'phone_auth_request.g.dart';

@JsonSerializable()
class PhoneAuthRequest {
  final String phoneNumber;

  PhoneAuthRequest({required this.phoneNumber});

  factory PhoneAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneAuthRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneAuthRequestToJson(this);
}
