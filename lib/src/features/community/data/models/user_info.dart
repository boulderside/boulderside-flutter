class UserInfo {
  final int id;
  final String nickname;
  final String? profileImageUrl;

  UserInfo({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}
