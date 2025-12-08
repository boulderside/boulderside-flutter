import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';

class BoulderModel {
  /// 바위 id
  final int id;

  /// 바위 이름
  final String name;

  /// 바위 설명
  final String description;

  /// 섹터 이름
  final String sectorName;

  /// 지역 코드
  final String areaCode;

  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 시도
  final String province;

  /// 시군구
  final String city;

  /// 바위 좋아요 갯수
  final int likeCount;

  /// 바위 조회수
  final int viewCount;

  /// 이미지 정보
  final List<ImageInfoModel> imageInfoList;

  /// 바위를 현재 로그인한 사용자가 좋아요를 했는지 여부
  final bool liked;

  /// 생성 시각
  final DateTime createdAt;

  /// 업데이트 시각
  final DateTime updatedAt;

  const BoulderModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sectorName,
    required this.areaCode,
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.city,
    required this.likeCount,
    required this.viewCount,
    required this.imageInfoList,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  BoulderModel copyWith({
    int? likeCount,
    bool? liked,
    int? viewCount,
    List<ImageInfoModel>? imageInfoList,
  }) {
    return BoulderModel(
      id: id,
      name: name,
      description: description,
      sectorName: sectorName,
      areaCode: areaCode,
      latitude: latitude,
      longitude: longitude,
      province: province,
      city: city,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      imageInfoList: imageInfoList ?? this.imageInfoList,
      liked: liked ?? this.liked,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
