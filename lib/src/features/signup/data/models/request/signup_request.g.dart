// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      nickname: json['nickname'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userRole: $enumDecode(_$UserRoleEnumMap, json['userRole']),
      userSex: $enumDecode(_$UserSexEnumMap, json['userSex']),
      userLevel: $enumDecode(_$LevelEnumMap, json['userLevel']),
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) =>
    <String, dynamic>{
      'nickname': instance.nickname,
      'phoneNumber': instance.phoneNumber,
      'userRole': _$UserRoleEnumMap[instance.userRole]!,
      'userSex': _$UserSexEnumMap[instance.userSex]!,
      'userLevel': _$LevelEnumMap[instance.userLevel]!,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

const _$UserRoleEnumMap = {
  UserRole.roleUser: 'ROLE_USER',
  UserRole.roleAdmin: 'ROLE_ADMIN',
};

const _$UserSexEnumMap = {UserSex.man: 'MAN', UserSex.woman: 'WOMAN'};

const _$LevelEnumMap = {
  Level.v0: 'V0',
  Level.v1: 'V1',
  Level.v2: 'V2',
  Level.v3: 'V3',
  Level.v4: 'V4',
  Level.v5: 'V5',
  Level.v6: 'V6',
  Level.v7: 'V7',
  Level.v8: 'V8',
  Level.v9: 'V9',
  Level.v10: 'V10',
  Level.v11: 'V11',
  Level.v12: 'V12',
  Level.v13: 'V13',
  Level.v14: 'V14',
  Level.v15: 'V15',
  Level.v16: 'V16',
};
