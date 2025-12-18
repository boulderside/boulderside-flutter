import 'package:boulderside_flutter/src/features/mypage/data/models/notice_response.dart';

class NoticePageResponse {
  NoticePageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.hasNext,
  });

  final List<NoticeResponse> content;
  final int page;
  final int size;
  final int totalElements;
  final bool hasNext;

  factory NoticePageResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['content'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(NoticeResponse.fromJson)
        .toList();
    return NoticePageResponse(
      content: items,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? items.length,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? items.length,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
