import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';

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
          .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
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
          .map((item) => BoulderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? list.length,
    );
  }
}
