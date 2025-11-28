class RouteModel {
  /// 루트 id
  final int id;

  /// 바위 id
  final int boulderId;

  /// 루트 이름
  final String name;

  /// 루트 레벨
  final String routeLevel;

  /// 루트 좋아요 갯수
  final int likeCount;

  /// 루트를 현재 로그인한 사용자가 좋아요를 했는지 여부
  final bool liked;

  /// 조회수
  final int viewCount;

  /// 루트 등반자 수
  final int climberCount;

  /// 댓글 수
  final int commentCount;

  /// 생성 시각
  final DateTime createdAt;

  /// 업데이트 시각
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.boulderId,
    required this.name,
    required this.routeLevel,
    required this.likeCount,
    required this.liked,
    required this.viewCount,
    required this.climberCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['routeId'] ?? json['id'] ?? 0,
      boulderId: json['boulderId'] ?? 0,
      name: json['name'] ?? '',
      routeLevel: json['routeLevel'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      liked: json['liked'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      climberCount: json['climberCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  // Backward compatibility getters for existing widgets
  int get likes => likeCount;
  bool get isLiked => liked;
  int get climbers => climberCount;
}
