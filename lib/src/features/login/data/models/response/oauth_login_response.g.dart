// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthLoginResponse _$OAuthLoginResponseFromJson(Map<String, dynamic> json) =>
    OAuthLoginResponse(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      isNew: json['isNew'] as bool,
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$OAuthLoginResponseToJson(OAuthLoginResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'isNew': instance.isNew,
      'profileImageUrl': instance.profileImageUrl,
    };
