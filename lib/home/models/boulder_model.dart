class BoulderModel {
  /// 바위 id
  final int id;

  /// 바위 이름
  final String name;

  /// 바위 이미지 url
  final String imageUrl;

  /// 바위 좋아요 갯수
  final int likes;

  /// 바위를 현재 로그인한 사용자가 좋아요를 했는지 여부
  final bool isLiked;

  /// 바위의 위치
  final String location;

  BoulderModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.likes,
    required this.isLiked,
    required this.location,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory BoulderModel.fromJson(Map<String, dynamic> json) {
    return BoulderModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      likes: json['likes'],
      isLiked: json['isLiked'],
      location: json['location'],
    );
  }
}
