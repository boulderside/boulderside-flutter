// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_link_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneLinkRequest _$PhoneLinkRequestFromJson(Map<String, dynamic> json) =>
    PhoneLinkRequest(
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$PhoneLinkRequestToJson(PhoneLinkRequest instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'password': instance.password,
    };
