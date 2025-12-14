import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:flutter/foundation.dart';

class LikedBoulderItemDto {
  const LikedBoulderItemDto({
    required this.likeId,
    required this.boulderId,
    required this.name,
    required this.province,
    required this.city,
    required this.likeCount,
    required this.viewCount,
    required this.liked,
    required this.likedAt,
  });

  final int likeId;
  final int boulderId;
  final String name;
  final String province;
  final String city;
  final int likeCount;
  final int viewCount;
  final bool liked;
  final DateTime likedAt;

  factory LikedBoulderItemDto.fromJson(Map<String, dynamic> json) {
    final province = json['province'] as String? ?? '';
    final city = json['city'] as String? ?? '';

    // Debug logging
    debugPrint('[LikedBoulderItemDto] Parsing boulder:');
    debugPrint('  - boulderId: ${json['boulderId']}');
    debugPrint('  - name: ${json['name']}');
    debugPrint('  - province: "$province"');
    debugPrint('  - city: "$city"');
    debugPrint('  - Raw JSON: $json');

    return LikedBoulderItemDto(
      likeId: _parseInt(json['likeId']),
      boulderId: _parseInt(json['boulderId']),
      name: json['name'] as String? ?? '',
      province: province,
      city: city,
      likeCount: _parseInt(json['likeCount']),
      viewCount: _parseInt(json['viewCount']),
      liked: json['liked'] as bool? ?? true,
      likedAt: _parseDateTime(json['likedAt']),
    );
  }

  BoulderModel toDomain() {
    return BoulderModel(
      id: boulderId,
      name: name,
      description: '',
      sectorName: '',
      areaCode: '',
      latitude: 0.0,
      longitude: 0.0,
      province: province,
      city: city,
      likeCount: likeCount,
      viewCount: viewCount,
      imageInfoList: const [],
      liked: liked,
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