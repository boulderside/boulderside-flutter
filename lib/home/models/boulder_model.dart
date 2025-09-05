import 'package:boulderside_flutter/home/models/image_info_model.dart';

class BoulderModel {
  /// 바위 id
  final int id;

  /// 바위 이름
  final String name;

  /// 바위 설명
  final String description;

  /// 위도
  final double latitude;

  /// 경도
  final double longitude;

  /// 시도
  final String province;

  /// 시군구
  final String? city;

  /// 바위 좋아요 갯수
  final int likeCount;

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
    required this.latitude,
    required this.longitude,
    required this.province,
    required this.city,
    required this.likeCount,
    required this.imageInfoList,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory BoulderModel.fromJson(Map<String, dynamic> json) {
    return BoulderModel(
      id: _parseToInt(json['id']) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: _parseToDouble(json['latitude']) ?? 0.0,
      longitude: _parseToDouble(json['longitude']) ?? 0.0,
      province: json['province'] ?? '',
      city: json['city'],
      likeCount: _parseToInt(json['likeCount']) ?? 0,
      imageInfoList: (json['imageInfoList'] as List? ?? [])
          .map((e) => ImageInfoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      liked: json['liked'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
