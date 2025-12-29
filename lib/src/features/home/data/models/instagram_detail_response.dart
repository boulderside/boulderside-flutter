import 'package:boulderside_flutter/src/features/community/data/models/user_info.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_detail.dart';

class InstagramDetailResponse {
  const InstagramDetailResponse({
    required this.id,
    required this.url,
    required this.userInfo,
    required this.routes,
    required this.likeCount,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String url;
  final UserInfo userInfo;
  final List<InstagramRouteInfo> routes;
  final int likeCount;
  final bool liked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory InstagramDetailResponse.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List? ?? [];
    return InstagramDetailResponse(
      id: _parseInt(json['instagramId']),
      url: json['url'] as String? ?? '',
      userInfo: UserInfo.fromJson(
        (json['userInfo'] as Map<String, dynamic>?) ?? {},
      ),
      routes: routes
          .map(
            (item) => InstagramRouteInfo(
              routeId: _parseInt((item as Map<String, dynamic>)['routeId']),
              name: item['name'] as String? ?? '',
              boulderName: item['boulderName'] as String? ?? '',
            ),
          )
          .toList(),
      likeCount: _parseInt(json['likeCount']),
      liked: json['isLiked'] as bool? ?? json['liked'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  InstagramDetail toDomain() {
    return InstagramDetail(
      id: id,
      url: url,
      userInfo: userInfo,
      routes: routes,
      likeCount: likeCount,
      liked: liked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
