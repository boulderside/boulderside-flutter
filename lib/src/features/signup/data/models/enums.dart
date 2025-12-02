import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('ROLE_USER')
  roleUser,
  @JsonValue('ROLE_ADMIN')
  roleAdmin,
}

enum UserSex {
  @JsonValue('MAN')
  man,
  @JsonValue('WOMAN')
  woman,
}

enum Level {
  @JsonValue('V0')
  v0,
  @JsonValue('V1')
  v1,
  @JsonValue('V2')
  v2,
  @JsonValue('V3')
  v3,
  @JsonValue('V4')
  v4,
  @JsonValue('V5')
  v5,
  @JsonValue('V6')
  v6,
  @JsonValue('V7')
  v7,
  @JsonValue('V8')
  v8,
  @JsonValue('V9')
  v9,
  @JsonValue('V10')
  v10,
  @JsonValue('V11')
  v11,
  @JsonValue('V12')
  v12,
  @JsonValue('V13')
  v13,
  @JsonValue('V14')
  v14,
  @JsonValue('V15')
  v15,
  @JsonValue('V16')
  v16,
}
