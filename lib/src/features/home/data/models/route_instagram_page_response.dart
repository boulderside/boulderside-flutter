import 'package:boulderside_flutter/src/features/home/data/models/route_instagram_response.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram_page.dart';

class RouteInstagramPageResponse {
  RouteInstagramPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<RouteInstagram> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory RouteInstagramPageResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return RouteInstagramPageResponse(
      content: list.map((item) {
        return RouteInstagramResponse.fromJson(
          item as Map<String, dynamic>,
        ).toDomain();
      }).toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? list.length,
    );
  }

  RouteInstagramPage toDomain() {
    return RouteInstagramPage(
      items: content,
      nextCursor: nextCursor,
      hasNext: hasNext,
    );
  }
}
