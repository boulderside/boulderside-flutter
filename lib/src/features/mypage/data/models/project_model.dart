import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_info.dart';

class ProjectModel {
  const ProjectModel({
    required this.projectId,
    required this.routeId,
    required this.userId,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.memo,
    this.sessions = const <ProjectSessionModel>[],
    this.routeInfo,
  });

  final int projectId;
  final int routeId;
  final int userId;
  final bool completed;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProjectSessionModel> sessions;
  final RouteInfo? routeInfo;

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['sessions'] ?? json['attemptHistories'];
    final attempts =
        (rawSessions as List?)
            ?.map(
              (item) =>
                  ProjectSessionModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        <ProjectSessionModel>[];

    RouteInfo? routeInfo;
    if (json['routeInfo'] != null) {
      routeInfo = RouteInfo.fromJson(json['routeInfo'] as Map<String, dynamic>);
    }

    return ProjectModel(
      projectId: _parseInt(json['projectId']),
      routeId: _parseInt(json['routeId']),
      userId: _parseInt(json['userId']),
      completed: json['completed'] == true,
      memo: json['memo'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      sessions: attempts,
      routeInfo: routeInfo,
    );
  }

  ProjectModel copyWith({
    bool? completed,
    String? memo,
    DateTime? updatedAt,
    List<ProjectSessionModel>? sessions,
    RouteInfo? routeInfo,
  }) {
    return ProjectModel(
      projectId: projectId,
      routeId: routeId,
      userId: userId,
      completed: completed ?? this.completed,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessions: sessions ?? this.sessions,
      routeInfo: routeInfo ?? this.routeInfo,
    );
  }

  String get displayTitle =>
      routeInfo?.name.isNotEmpty == true ? routeInfo!.name : '루트 #$routeId';

  String get displaySubtitle {
    if (routeInfo == null) {
      return '루트 정보를 불러오는 중...';
    }
    final buffer = StringBuffer();
    if (routeInfo!.routeLevel.isNotEmpty) {
      buffer.write(routeInfo!.routeLevel);
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
