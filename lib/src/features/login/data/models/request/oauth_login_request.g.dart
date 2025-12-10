// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OAuthLoginRequest _$OAuthLoginRequestFromJson(Map<String, dynamic> json) =>
    OAuthLoginRequest(
      providerType: json['providerType'] as String,
      identityToken: json['identityToken'] as String,
    );

Map<String, dynamic> _$OAuthLoginRequestToJson(OAuthLoginRequest instance) =>
    <String, dynamic>{
      'providerType': instance.providerType,
      'identityToken': instance.identityToken,
    };
