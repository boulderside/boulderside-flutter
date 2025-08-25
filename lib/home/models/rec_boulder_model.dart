import 'package:boulderside_flutter/home/models/image_info_model.dart';

class RecBoulderModel {
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

  RecBoulderModel({
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
  factory RecBoulderModel.fromJson(Map<String, dynamic> json) {
    return RecBoulderModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      province: json['province'],
      city: json['city'],
      likeCount: json['likeCount'],
      imageInfoList: (json['imageInfoList'] as List)
          .map((e) => ImageInfoModel.fromJson(e))
          .toList(),
      liked: json['liked'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
