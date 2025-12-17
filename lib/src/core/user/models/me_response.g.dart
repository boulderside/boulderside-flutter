// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) => MeResponse(
  email: json['email'] as String,
  nickname: json['nickname'] as String,
  profileImageUrl: json['profileImageUrl'] as String,
  marketingConsentAgreed: json['marketingConsentAgreed'] as bool? ?? false,
);

Map<String, dynamic> _$MeResponseToJson(MeResponse instance) =>
    <String, dynamic>{
      'email': instance.email,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'marketingConsentAgreed': instance.marketingConsentAgreed,
    };
