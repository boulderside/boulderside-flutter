import 'package:boulderside_flutter/home/models/image_info_model.dart';

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

  BoulderModel({
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

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory BoulderModel.fromJson(Map<String, dynamic> json) {
    return BoulderModel(
      id: json['boulderId'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      sectorName: json['sectorName'] ?? '',
      areaCode: json['areaCode'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      imageInfoList: (json['imageInfoList'] ?? [])
          .map<ImageInfoModel>((e) => ImageInfoModel.fromJson(e))
          .toList(),
      liked: json['liked'] ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
