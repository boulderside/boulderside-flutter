class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.nickname,
    this.profileImageUrl,
    this.blockedAt,
  });

  final int id;
  final String nickname;
  final String? profileImageUrl;
  final DateTime? blockedAt;

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    final blockedAtRaw = json['blockedAt'] as String?;
    return BlockedUser(
      id: _parseId(json),
      nickname: json['nickname'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      blockedAt: blockedAtRaw != null ? DateTime.tryParse(blockedAtRaw) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockedUserId': id,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
      'blockedAt': blockedAt?.toIso8601String(),
    };
  }
}

int _parseId(Map<String, dynamic> json) {
  final blockedUserId = json['blockedUserId'];
  if (blockedUserId is num) {
    return blockedUserId.toInt();
  }
  final userId = json['userId'];
  if (userId is num) {
    return userId.toInt();
  }
  return 0;
}
