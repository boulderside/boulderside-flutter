class ProjectSummaryResponse {
  const ProjectSummaryResponse({
    required this.highestCompletedLevel,
    required this.completedRouteCount,
    required this.ongoingProjectCount,
    required this.completedRoutes,
    required this.completionIdsByLevel,
  });

  final String? highestCompletedLevel;
  final int completedRouteCount;
  final int ongoingProjectCount;
  final List<CompletedRouteCount> completedRoutes;
  final Map<String, List<int>> completionIdsByLevel;

  factory ProjectSummaryResponse.fromJson(Map<String, dynamic> json) {
    final routes = (json['completedRoutes'] as List<dynamic>? ?? <dynamic>[])
        .map(
          (item) =>
              CompletedRouteCount.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    final completionIdsMap = <String, List<int>>{};
    final rawMap = json['completionIdsByLevel'] as Map<String, dynamic>?;

    if (rawMap != null) {
      rawMap.forEach((key, value) {
        if (value is List) {
          final ids = value.map((e) => _parseInt(e)).toList();
          completionIdsMap[key] = ids;
        }
      });
    }

    return ProjectSummaryResponse(
      highestCompletedLevel: _parseLevel(json['highestCompletedLevel']),
      completedRouteCount: _parseInt(json['completedRouteCount']),
      ongoingProjectCount: _parseInt(json['ongoingProjectCount']),
      completedRoutes: routes,
      completionIdsByLevel: completionIdsMap,
    );
  }
}

class CompletedRouteCount {
  const CompletedRouteCount({
    required this.completedDate,
    required this.cumulativeCount,
  });

  final DateTime completedDate;
  final int cumulativeCount;

  factory CompletedRouteCount.fromJson(Map<String, dynamic> json) {
    return CompletedRouteCount(
      completedDate: _parseDate(json['completedDate']),
      cumulativeCount: _parseInt(json['cumulativeCount']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  final parsed = DateTime.tryParse(value.toString());
  return parsed ?? DateTime.now();
}

String? _parseLevel(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    return value['displayName'] as String? ??
        value['label'] as String? ??
        value['name'] as String? ??
        value['value'] as String?;
  }
  return value.toString();
}