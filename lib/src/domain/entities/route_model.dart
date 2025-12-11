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

  /// 연결된 바위 이름
  final String? boulderName;

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

  const RouteModel({
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
    this.boulderName,
    required this.likeCount,
    required this.liked,
    required this.viewCount,
    required this.climberCount,
    required this.commentCount,
    required this.imageInfoList,
    required this.createdAt,
    required this.updatedAt,
  });

  // Backward compatibility getters for existing widgets
  int get likes => likeCount;
  bool get isLiked => liked;
  int get climbers => climberCount;

  RouteModel copyWith({
    int? likeCount,
    bool? liked,
    int? viewCount,
    int? climberCount,
    int? commentCount,
    List<ImageInfoModel>? imageInfoList,
    String? boulderName,
  }) {
    return RouteModel(
      id: id,
      boulderId: boulderId,
      province: province,
      city: city,
      name: name,
      pioneerName: pioneerName,
      latitude: latitude,
      longitude: longitude,
      sectorName: sectorName,
      areaCode: areaCode,
      routeLevel: routeLevel,
      boulderName: boulderName ?? this.boulderName,
      likeCount: likeCount ?? this.likeCount,
      liked: liked ?? this.liked,
      viewCount: viewCount ?? this.viewCount,
      climberCount: climberCount ?? this.climberCount,
      commentCount: commentCount ?? this.commentCount,
      imageInfoList: imageInfoList ?? this.imageInfoList,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
