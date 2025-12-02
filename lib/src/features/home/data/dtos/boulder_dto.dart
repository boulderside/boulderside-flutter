import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/image_info_dto.dart';

class BoulderDto {
  const BoulderDto({
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

  final int id;
  final String name;
  final String description;
  final String sectorName;
  final String areaCode;
  final double latitude;
  final double longitude;
  final String province;
  final String city;
  final int likeCount;
  final int viewCount;
  final List<ImageInfoDto> imageInfoList;
  final bool liked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BoulderDto.fromJson(Map<String, dynamic> json) => BoulderDto(
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
    imageInfoList: (json['imageInfoList'] as List<dynamic>? ?? [])
        .map((e) => ImageInfoDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    liked: json['liked'] ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  BoulderModel toDomain() => BoulderModel(
    id: id,
    name: name,
    description: description,
    sectorName: sectorName,
    areaCode: areaCode,
    latitude: latitude,
    longitude: longitude,
    province: province,
    city: city,
    likeCount: likeCount,
    viewCount: viewCount,
    imageInfoList: imageInfoList.map((e) => e.toDomain()).toList(),
    liked: liked,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
