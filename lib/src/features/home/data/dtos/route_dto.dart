import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/image_info_dto.dart';

class RouteDto {
  const RouteDto({
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

  final int id;
  final int boulderId;
  final String province;
  final String city;
  final String name;
  final String pioneerName;
  final double latitude;
  final double longitude;
  final String sectorName;
  final String areaCode;
  final String routeLevel;
  final int likeCount;
  final bool liked;
  final int viewCount;
  final int climberCount;
  final int commentCount;
  final List<ImageInfoDto> imageInfoList;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RouteDto.fromJson(Map<String, dynamic> json) => RouteDto(
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
    imageInfoList: (json['imageInfoList'] as List<dynamic>? ?? [])
        .map((e) => ImageInfoDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt:
        DateTime.tryParse(json['createdAt'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  RouteModel toDomain() => RouteModel(
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
    likeCount: likeCount,
    liked: liked,
    viewCount: viewCount,
    climberCount: climberCount,
    commentCount: commentCount,
    imageInfoList: imageInfoList.map((e) => e.toDomain()).toList(),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
