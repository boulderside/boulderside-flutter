import 'package:json_annotation/json_annotation.dart';

part 'verify_phone_code_request.g.dart';

@JsonSerializable()
class VerifyPhoneCodeRequest {
  final String phoneNumber;
  final String code;

  VerifyPhoneCodeRequest({required this.phoneNumber, required this.code});

  factory VerifyPhoneCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPhoneCodeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyPhoneCodeRequestToJson(this);
}
