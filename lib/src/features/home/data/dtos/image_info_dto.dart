import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';

class ImageInfoDto {
  const ImageInfoDto({
    required this.targetType,
    required this.imageUrl,
    required this.orderIndex,
  });

  final String targetType;
  final String imageUrl;
  final int orderIndex;

  factory ImageInfoDto.fromJson(Map<String, dynamic> json) => ImageInfoDto(
    targetType: json['targetType'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    orderIndex: json['orderIndex'] ?? 0,
  );

  ImageInfoModel toDomain() => ImageInfoModel(
    targetType: targetType,
    imageUrl: imageUrl,
    orderIndex: orderIndex,
  );
}
