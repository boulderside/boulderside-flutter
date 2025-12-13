class RouteInfo {
  const RouteInfo({
    required this.name,
    required this.routeLevel,
    required this.climberCount,
    required this.likeCount,
    required this.viewCount,
    required this.commentCount,
  });

  final String name;
  final String routeLevel;
  final int climberCount;
  final int likeCount;
  final int viewCount;
  final int commentCount;

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      name: json['name'] as String? ?? '',
      routeLevel: json['routeLevel'] as String? ?? '',
      climberCount: _parseInt(json['climberCount']),
      likeCount: _parseInt(json['likeCount']),
      viewCount: _parseInt(json['viewCount']),
      commentCount: _parseInt(json['commentCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'routeLevel': routeLevel,
      'climberCount': climberCount,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'commentCount': commentCount,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
