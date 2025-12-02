import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/image_info_dto.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/route_dto.dart';

class RouteDetailModel {
  final RouteModel route;
  final List<ImageInfoModel> images;
  final String? description;
  final String? boulderName;
  final String? province;
  final String? city;

  const RouteDetailModel({
    required this.route,
    required this.images,
    this.description,
    this.boulderName,
    this.province,
    this.city,
  });

  factory RouteDetailModel.fromJson(Map<String, dynamic> json) {
    final routeJson = (json['route'] as Map<String, dynamic>?) ?? json;
    final dynamic rawImages =
        json['imageInfoList'] ??
        routeJson['imageInfoList'] ??
        json['images'] ??
        routeJson['images'];
    final imagesJson = rawImages is List ? rawImages : <dynamic>[];

    return RouteDetailModel(
      route: RouteDto.fromJson(routeJson).toDomain(),
      images: imagesJson
          .map(
            (e) => ImageInfoDto.fromJson(e as Map<String, dynamic>).toDomain(),
          )
          .toList(),
      description:
          json['description'] ??
          routeJson['description'] ??
          json['routeDescription'],
      boulderName: json['boulderName'] ?? routeJson['boulderName'],
      province: json['province'] ?? routeJson['province'],
      city: json['city'] ?? routeJson['city'],
    );
  }

  String get location {
    final parts = <String>[];
    if ((province ?? '').isNotEmpty) {
      parts.add(province!.trim());
    }
    if ((city ?? '').isNotEmpty) {
      parts.add(city!.trim());
    }
    return parts.join(' ').trim();
  }
}
