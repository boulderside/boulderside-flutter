class RouteModel {
  /// 루트 id
  final int id;

  /// 루트 이름
  final String name;

  /// 루트 레벨
  final String routeLevel;

  /// 루트 좋아요 갯수
  final int likes;

  /// 루트를 현재 로그인한 사용자가 좋아요를 했는지 여부
  final bool isLiked;

  /// 루트 등반자 수
  final int climbers;

  RouteModel({
    required this.id,
    required this.name,
    required this.routeLevel,
    required this.likes,
    required this.isLiked,
    required this.climbers,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      routeLevel: json['routeLevel'] ?? '',
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      climbers: json['climbers'] ?? 0,
    );
  }
}
