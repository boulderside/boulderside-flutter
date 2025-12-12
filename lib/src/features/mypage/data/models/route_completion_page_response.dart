import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';

class RouteCompletionPageResponse {
  RouteCompletionPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<RouteCompletionModel> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory RouteCompletionPageResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['content'] as List? ?? <dynamic>[];
    return RouteCompletionPageResponse(
      content: items
          .map((item) => RouteCompletionModel.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool? ?? false,
      size: json['size'] as int? ?? items.length,
    );
  }
}
