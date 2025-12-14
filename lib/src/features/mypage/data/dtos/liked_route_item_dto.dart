import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:flutter/foundation.dart';

class LikedRouteItemDto {
  const LikedRouteItemDto({
    required this.likeId,
    required this.routeId,
    required this.name,
    required this.boulderId,
    required this.boulderName,
    required this.routeLevel,
    required this.likeCount,
    required this.viewCount,
    required this.climberCount,
    required this.likedAt,
  });

  final int likeId;
  final int routeId;
  final String name;
  final int boulderId;
  final String boulderName;
  final String routeLevel;
  final int likeCount;
  final int viewCount;
  final int climberCount;
  final DateTime likedAt;

  factory LikedRouteItemDto.fromJson(Map<String, dynamic> json) {
    // Parse nested boulderInfo object
    final boulderInfo = json['boulderInfo'] as Map<String, dynamic>?;
    final boulderId = boulderInfo != null
        ? _parseInt(boulderInfo['boulderId'])
        : 0;
    final boulderName = boulderInfo != null
        ? (boulderInfo['name'] as String? ?? '')
        : '';

    // Debug logging
    debugPrint('[LikedRouteItemDto] Parsing route:');
    debugPrint('  - routeId: ${json['routeId']}');
    debugPrint('  - name: ${json['name']}');
    debugPrint('  - boulderInfo: $boulderInfo');
    debugPrint('  - boulderId: $boulderId');
    debugPrint('  - boulderName: "$boulderName"');

    return LikedRouteItemDto(
      likeId: _parseInt(json['likeId']),
      routeId: _parseInt(json['routeId']),
      name: json['name'] as String? ?? '',
      boulderId: boulderId,
      boulderName: boulderName,
      routeLevel: json['routeLevel'] as String? ?? '',
      likeCount: _parseInt(json['likeCount']),
      viewCount: _parseInt(json['viewCount']),
      climberCount: _parseInt(json['climberCount']),
      likedAt: _parseDateTime(json['likedAt']),
    );
  }

  RouteModel toDomain() {
    return RouteModel(
      id: routeId,
      boulderId: boulderId,
      province: '',
      city: '',
      name: name,
      pioneerName: '',
      latitude: 0.0,
      longitude: 0.0,
      sectorName: '',
      areaCode: '',
      routeLevel: routeLevel,
      boulderName: boulderName,
      likeCount: likeCount,
      liked: true,
      viewCount: viewCount,
      climberCount: climberCount,
      commentCount: 0,
      imageInfoList: const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: likedAt,
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
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}
