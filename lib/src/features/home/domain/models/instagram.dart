import 'package:boulderside_flutter/src/features/community/data/models/user_info.dart';

class Instagram {
  const Instagram({
    required this.id,
    required this.url,
    required this.routeIds,
    required this.likeCount,
    required this.liked,
    this.userInfo,
    this.createdAt,
  });

  final int id;
  final String url;
  final List<int> routeIds;
  final int likeCount;
  final bool liked;
  final UserInfo? userInfo;
  final DateTime? createdAt;

  Instagram copyWith({
    int? id,
    String? url,
    List<int>? routeIds,
    int? likeCount,
    bool? liked,
    UserInfo? userInfo,
    DateTime? createdAt,
  }) {
    return Instagram(
      id: id ?? this.id,
      url: url ?? this.url,
      routeIds: routeIds ?? this.routeIds,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
      userInfo: userInfo ?? this.userInfo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
