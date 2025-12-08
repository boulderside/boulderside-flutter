import 'package:boulderside_flutter/src/domain/entities/image_info_model.dart';

class ApproachModel {
  const ApproachModel({
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

  final int id;
  final int boulderId;
  final int orderIndex;
  final String transportInfo;
  final String parkingInfo;
  final int duration;
  final String tip;
  final List<ApproachPointModel> points;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ApproachPointModel {
  const ApproachPointModel({
    required this.id,
    required this.orderIndex,
    required this.name,
    required this.description,
    required this.note,
    required this.images,
  });

  final int id;
  final int orderIndex;
  final String name;
  final String description;
  final String note;
  final List<ImageInfoModel> images;
}
