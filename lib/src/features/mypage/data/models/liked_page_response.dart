import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/boulder_dto.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/route_dto.dart';

class LikedRoutePageResponse {
  LikedRoutePageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<RouteModel> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory LikedRoutePageResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return LikedRoutePageResponse(
      content: list
          .map(
            (item) =>
                RouteDto.fromJson(item as Map<String, dynamic>).toDomain(),
          )
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? list.length,
    );
  }
}

class LikedBoulderPageResponse {
  LikedBoulderPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<BoulderModel> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory LikedBoulderPageResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return LikedBoulderPageResponse(
      content: list
          .map(
            (item) =>
                BoulderDto.fromJson(item as Map<String, dynamic>).toDomain(),
          )
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? list.length,
    );
  }
}
