import 'package:boulderside_flutter/src/features/community/data/models/user_info.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instagram_response.g.dart';

@JsonSerializable()
class InstagramResponse {
  const InstagramResponse({
    required this.id,
    required this.url,
    required this.routes,
    required this.routeIds,
    required this.likeCount,
    required this.liked,
    required this.userInfo,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  @JsonKey(name: 'instagramId')
  final int id;
  final String url;
  @JsonKey(defaultValue: <InstagramRouteInfoResponse>[])
  final List<InstagramRouteInfoResponse> routes;
  @JsonKey(defaultValue: <int>[])
  final List<int> routeIds;
  @JsonKey(defaultValue: 0, readValue: _readInstagramLikeCount)
  final int likeCount;
  @JsonKey(defaultValue: false, readValue: _readInstagramLiked)
  final bool liked;
  @JsonKey(defaultValue: _emptyUserInfo, readValue: _readInstagramUserInfo)
  final UserInfo userInfo;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory InstagramResponse.fromJson(Map<String, dynamic> json) =>
      _$InstagramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramResponseToJson(this);

  Instagram toDomain() {
    final derivedRouteIds = routes.isNotEmpty
        ? routes.map((route) => route.routeId).toList()
        : routeIds;
    return Instagram(
      id: id,
      url: url,
      routeIds: derivedRouteIds,
      likeCount: likeCount,
      liked: liked,
      userInfo: userInfo,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class InstagramRouteInfoResponse {
  const InstagramRouteInfoResponse({
    required this.routeId,
    required this.name,
    required this.boulderName,
  });

  final int routeId;
  final String name;
  final String boulderName;

  factory InstagramRouteInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$InstagramRouteInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramRouteInfoResponseToJson(this);
}

Object? _readInstagramLiked(Map<dynamic, dynamic> json, String key) {
  return json['liked'] ?? json['isLiked'];
}

Map<String, dynamic> _readInstagramUserInfo(
  Map<dynamic, dynamic> json,
  String key,
) {
  final info = json['userInfo'];
  if (info is Map<String, dynamic>) {
    return info;
  }
  return _emptyUserInfo;
}

const Map<String, dynamic> _emptyUserInfo = {
  'id': 0,
  'nickname': '',
  'profileImageUrl': null,
};

Object? _readInstagramLikeCount(Map<dynamic, dynamic> json, String key) {
  return json['likeCount'] ?? json['totalLikes'];
}
