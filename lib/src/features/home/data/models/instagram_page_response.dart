import 'package:boulderside_flutter/src/features/home/data/models/instagram_response.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_page.dart';

class InstagramPageResponse {
  InstagramPageResponse({
    required this.content,
    this.nextCursor,
    required this.hasNext,
    required this.size,
  });

  final List<Instagram> content;
  final int? nextCursor;
  final bool hasNext;
  final int size;

  factory InstagramPageResponse.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List? ?? [];
    return InstagramPageResponse(
      content: list.map((item) {
        return InstagramResponse.fromJson(
          item as Map<String, dynamic>,
        ).toDomain();
      }).toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext: json['hasNext'] ?? false,
      size: json['size'] ?? list.length,
    );
  }

  InstagramPage toDomain() {
    return InstagramPage(
      items: content,
      nextCursor: nextCursor,
      hasNext: hasNext,
    );
  }
}
