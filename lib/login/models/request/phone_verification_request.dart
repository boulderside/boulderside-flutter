import 'package:json_annotation/json_annotation.dart';

part 'phone_verification_request.g.dart';

@JsonSerializable()
class PhoneVerificationRequest {
  final String phoneNumber;

  PhoneVerificationRequest({required this.phoneNumber});

  factory PhoneVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$PhoneVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneVerificationRequestToJson(this);
}
