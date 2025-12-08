import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/approach_model.dart';

class ApproachDto {
  ApproachDto({
    required this.id,
    required this.boulderId,
    required this.orderIndex,
    required this.transportInfo,
    required this.parkingInfo,
    required this.duration,
    required this.tip,
    required this.points,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApproachDto.fromJson(Map<String, dynamic> json) {
    return ApproachDto(
      id: (json['id'] as num).toInt(),
      boulderId: (json['boulderId'] as num).toInt(),
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      transportInfo: json['transportInfo'] as String? ?? '',
      parkingInfo: json['parkingInfo'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      tip: json['tip'] as String? ?? '',
      points: (json['points'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => ApproachPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final int id;
  final int boulderId;
  final int orderIndex;
  final String transportInfo;
  final String parkingInfo;
  final int duration;
  final String tip;
  final List<ApproachPointDto> points;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApproachModel toDomain() {
    return ApproachModel(
      id: id,
      boulderId: boulderId,
      orderIndex: orderIndex,
      transportInfo: transportInfo,
      parkingInfo: parkingInfo,
      duration: duration,
      tip: tip,
      points: points.map((point) => point.toDomain()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class ApproachPointDto {
  ApproachPointDto({
    required this.id,
    required this.orderIndex,
    required this.name,
    required this.description,
    required this.note,
    required this.images,
  });

  factory ApproachPointDto.fromJson(Map<String, dynamic> json) {
    return ApproachPointDto(
      id: (json['id'] as num).toInt(),
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      note: json['note'] as String? ?? '',
      images: (json['images'] as List<dynamic>? ?? <dynamic>[])
          .map((e) => ApproachImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final int orderIndex;
  final String name;
  final String description;
  final String note;
  final List<ApproachImageDto> images;

  ApproachPointModel toDomain() {
    return ApproachPointModel(
      id: id,
      orderIndex: orderIndex,
      name: name,
      description: description,
      note: note,
      images: images.map((img) => img.toDomain()).toList(),
    );
  }
}

class ApproachImageDto {
  ApproachImageDto({
    required this.imageUrl,
    required this.orderIndex,
    required this.imageDomainType,
  });

  factory ApproachImageDto.fromJson(Map<String, dynamic> json) {
    return ApproachImageDto(
      imageUrl: json['imageUrl'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      imageDomainType: json['imageDomainType'] as String? ?? '',
    );
  }

  final String imageUrl;
  final int orderIndex;
  final String imageDomainType;

  ImageInfoModel toDomain() {
    return ImageInfoModel(
      targetType: imageDomainType,
      imageUrl: imageUrl,
      orderIndex: orderIndex,
    );
  }
}
