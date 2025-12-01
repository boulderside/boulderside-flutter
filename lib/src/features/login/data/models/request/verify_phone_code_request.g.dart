// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_phone_code_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyPhoneCodeRequest _$VerifyPhoneCodeRequestFromJson(
  Map<String, dynamic> json,
) => VerifyPhoneCodeRequest(
  phoneNumber: json['phoneNumber'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$VerifyPhoneCodeRequestToJson(
  VerifyPhoneCodeRequest instance,
) => <String, dynamic>{
  'phoneNumber': instance.phoneNumber,
  'code': instance.code,
};
