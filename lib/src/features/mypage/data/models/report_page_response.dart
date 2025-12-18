import 'package:boulderside_flutter/src/features/mypage/data/models/report_response.dart';

class ReportPageResponse {
  ReportPageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.hasNext,
  });

  final List<ReportResponse> content;
  final int page;
  final int size;
  final int totalElements;
  final bool hasNext;

  factory ReportPageResponse.fromJson(Map<String, dynamic> json) {
    final rawList =
        (json['content'] ?? json['reports']) as List<dynamic>? ?? <dynamic>[];
    final items = rawList
        .whereType<Map<String, dynamic>>()
        .map(ReportResponse.fromJson)
        .toList();
    return ReportPageResponse(
      content: items,
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? items.length,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? items.length,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}
