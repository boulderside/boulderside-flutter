// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_lookup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneLookupResponse _$PhoneLookupResponseFromJson(Map<String, dynamic> json) =>
    PhoneLookupResponse(
      exists: json['exists'] as bool,
      nickname: json['nickname'] as String?,
      phone: json['phone'] as String?,
      userRole: $enumDecodeNullable(_$UserRoleEnumMap, json['userRole']),
      userSex: $enumDecodeNullable(_$UserSexEnumMap, json['userSex']),
      userLevel: $enumDecodeNullable(_$LevelEnumMap, json['userLevel']),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$PhoneLookupResponseToJson(
  PhoneLookupResponse instance,
) => <String, dynamic>{
  'exists': instance.exists,
  'nickname': instance.nickname,
  'phone': instance.phone,
  'userRole': _$UserRoleEnumMap[instance.userRole],
  'userSex': _$UserSexEnumMap[instance.userSex],
  'userLevel': _$LevelEnumMap[instance.userLevel],
  'name': instance.name,
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
