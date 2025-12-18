import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';

class CompletionPageResponse {
  CompletionPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<CompletionResponse> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory CompletionPageResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['content'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (item) => CompletionResponse.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return CompletionPageResponse(
      content: items,
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool? ?? false,
      size: json['size'] as int? ?? items.length,
    );
  }
}
