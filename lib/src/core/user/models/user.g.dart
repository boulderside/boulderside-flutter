// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  email: json['email'] as String,
  nickname: json['nickname'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
  marketingConsentAgreed: json['marketingConsentAgreed'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'email': instance.email,
  'nickname': instance.nickname,
  'profileImageUrl': instance.profileImageUrl,
  'marketingConsentAgreed': instance.marketingConsentAgreed,
};
