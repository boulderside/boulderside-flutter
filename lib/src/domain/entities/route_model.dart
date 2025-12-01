import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';

class RouteModel {
  /// 루트 id
  final int id;

  /// 바위 id
  final int boulderId;

  /// 시도
  final String province;

  /// 시군구
  final String city;

  /// 루트 이름
  final String name;

  /// 개척자 이름
  final String pioneerName;

  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 섹터 이름
  final String sectorName;

  /// 지역 코드
  final String areaCode;

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

  /// 이미지 정보
  final List<ImageInfoModel> imageInfoList;

  /// 생성 시각
  final DateTime createdAt;

  /// 업데이트 시각
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.boulderId,
    required this.province,
    required this.city,
    required this.name,
    required this.pioneerName,
    required this.latitude,
    required this.longitude,
    required this.sectorName,
    required this.areaCode,
    required this.routeLevel,
    required this.likeCount,
    required this.liked,
    required this.viewCount,
    required this.climberCount,
    required this.commentCount,
    required this.imageInfoList,
    required this.createdAt,
    required this.updatedAt,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['routeId'] ?? json['id'] ?? 0,
      boulderId: json['boulderId'] ?? 0,
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      name: json['name'] ?? '',
      pioneerName: json['pioneerName'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      sectorName: json['sectorName'] ?? '',
      areaCode: json['areaCode'] ?? '',
      routeLevel: json['routeLevel'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      liked: json['liked'] ?? false,
      viewCount: json['viewCount'] ?? 0,
      climberCount: json['climberCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      imageInfoList: (json['imageInfoList'] ?? [])
          .map<ImageInfoModel>((e) => ImageInfoModel.fromJson(e))
          .toList(),
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
