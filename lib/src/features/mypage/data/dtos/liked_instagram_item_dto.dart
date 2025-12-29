import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';

class LikedInstagramItemDto {
  const LikedInstagramItemDto({
    required this.likeId,
    required this.instagramId,
    required this.url,
    required this.routeIds,
    required this.likeCount,
    required this.likedAt,
  });

  final int likeId;
  final int instagramId;
  final String url;
  final List<int> routeIds;
  final int likeCount;
  final DateTime likedAt;

  factory LikedInstagramItemDto.fromJson(Map<String, dynamic> json) {
    final instagram = json['instagram'] as Map<String, dynamic>?;
    final source = instagram ?? json;
    return LikedInstagramItemDto(
      likeId: _parseInt(json['likeId']),
      instagramId: _parseInt(source['instagramId']),
      url: source['url'] as String? ?? '',
      routeIds: _readRouteIds(source),
      likeCount: _parseInt(source['likeCount']),
      likedAt: _parseDateTime(json['likedAt']),
    );
  }

  Instagram toDomain() {
    return Instagram(
      id: instagramId,
      url: url,
      routeIds: routeIds,
      likeCount: likeCount,
      liked: true,
      createdAt: likedAt,
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<int> _parseIntList(dynamic value) {
  if (value is List) {
    return value.map(_parseInt).toList();
  }
  return const [];
}

List<int> _readRouteIds(Map<String, dynamic> source) {
  final routes = source['routes'];
  if (routes is List) {
    return routes
        .map((route) => _parseInt((route as Map<String, dynamic>)['routeId']))
        .toList();
  }
  return _parseIntList(source['routeIds']);
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
