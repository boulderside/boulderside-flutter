import 'package:boulderside_flutter/src/features/mypage/data/models/report_category.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/report_target_type.dart';

class ReportResponse {
  ReportResponse({
    required this.id,
    required this.targetType,
    required this.targetId,
    this.category,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final ReportTargetType targetType;
  final int targetId;
  final ReportCategory? category;
  final String reason;
  final String status;
  final DateTime createdAt;

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ReportResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      targetType:
          ReportTargetType.fromServerValue(json['targetType'] as String?),
      targetId: (json['targetId'] as num?)?.toInt() ?? 0,
      category: ReportCategory.fromServerValue(json['category'] as String?),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
