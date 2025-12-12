import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';

class ProjectPageResponse {
  ProjectPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<ProjectModel> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory ProjectPageResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['content'] as List? ?? <dynamic>[];
    return ProjectPageResponse(
      content: items
          .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] as bool? ?? false,
      size: json['size'] as int? ?? items.length,
    );
  }
}
