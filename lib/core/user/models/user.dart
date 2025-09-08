import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String email;
  final String nickname;
  final String? profileImageUrl;

  const User({
    required this.email,
    required this.nickname,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  // User 객체 복사 (일부 필드만 변경)
  User copyWith({String? email, String? nickname, String? profileImageUrl}) {
    return User(
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
