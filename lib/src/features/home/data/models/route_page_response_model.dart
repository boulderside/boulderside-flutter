import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/route_dto.dart';

class RoutePageResponseModel {
  final List<RouteModel> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  RoutePageResponseModel({
    required this.content,
    required this.nextCursor,
    required this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory RoutePageResponseModel.fromJson(Map<String, dynamic> json) {
    return RoutePageResponseModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => RouteDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      nextSubCursor: json['nextSubCursor'] as String?,
      hasNext: json['hasNext'] as bool,
      size: json['size'] as int,
    );
  }
}
