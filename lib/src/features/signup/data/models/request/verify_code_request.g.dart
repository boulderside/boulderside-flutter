// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_code_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyCodeRequest _$VerifyCodeRequestFromJson(Map<String, dynamic> json) =>
    VerifyCodeRequest(
      phoneNumber: json['phoneNumber'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyCodeRequestToJson(VerifyCodeRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'code': instance.code,
    };
