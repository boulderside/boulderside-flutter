import 'package:boulderside_flutter/src/domain/entities/route_model.dart';

class RouteCompletionModel {
  const RouteCompletionModel({
    required this.routeId,
    required this.userId,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.memo,
    this.route,
  });

  final int routeId;
  final int userId;
  final bool completed;
  final String? memo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RouteModel? route;

  factory RouteCompletionModel.fromJson(Map<String, dynamic> json) {
    return RouteCompletionModel(
      routeId: _parseInt(json['routeId']),
      userId: _parseInt(json['userId']),
      completed: json['completed'] == true,
      memo: json['memo'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  RouteCompletionModel copyWith({
    bool? completed,
    String? memo,
    DateTime? updatedAt,
    RouteModel? route,
  }) {
    return RouteCompletionModel(
      routeId: routeId,
      userId: userId,
      completed: completed ?? this.completed,
      memo: memo ?? this.memo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
