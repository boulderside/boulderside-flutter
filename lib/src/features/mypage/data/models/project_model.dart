import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';

class ProjectModel {
  const ProjectModel({
    required this.projectId,
    required this.routeId,
    required this.userId,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.memo,
    this.attemptHistories = const <ProjectAttemptHistoryModel>[],
    this.route,
  });

  final int projectId;
  final int routeId;
  final int userId;
  final bool completed;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProjectAttemptHistoryModel> attemptHistories;
  final RouteModel? route;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final attempts =
        (json['attemptHistories'] as List?)
            ?.map(
              (item) => ProjectAttemptHistoryModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList() ??
        <ProjectAttemptHistoryModel>[];
    return ProjectModel(
      projectId: _parseInt(json['projectId']),
      routeId: _parseInt(json['routeId']),
      userId: _parseInt(json['userId']),
      completed: json['completed'] == true,
      memo: json['memo'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      attemptHistories: attempts,
    );
  }

  ProjectModel copyWith({
    bool? completed,
    String? memo,
    DateTime? updatedAt,
    List<ProjectAttemptHistoryModel>? attemptHistories,
    RouteModel? route,
  }) {
    return ProjectModel(
      projectId: projectId,
      routeId: routeId,
      userId: userId,
      completed: completed ?? this.completed,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attemptHistories: attemptHistories ?? this.attemptHistories,
      route: route ?? this.route,
    );
  }

  String get displayTitle =>
      route?.name.isNotEmpty == true ? route!.name : '루트 #$routeId';

  String get displaySubtitle {
    if (route == null) {
      return '루트 정보를 불러오는 중...';
    }
    final buffer = StringBuffer();
    if (route!.routeLevel.isNotEmpty) {
      buffer.write(route!.routeLevel);
    }
    final location = '${route!.province} ${route!.city}'.trim();
    if (location.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.write(' · ');
      }
      buffer.write(location);
    }
    return buffer.isEmpty ? '자세한 정보 없음' : buffer.toString();
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDate(dynamic raw) {
  if (raw == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  if (raw is DateTime) {
    return raw;
  }
  return DateTime.tryParse(raw.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
