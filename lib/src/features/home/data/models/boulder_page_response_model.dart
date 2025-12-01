import 'package:boulderside_flutter/src/features/home/data/models/boulder_model.dart';

class BoulderPageResponseModel {
  final List<BoulderModel> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  BoulderPageResponseModel({
    required this.content,
    required this.nextCursor,
    required this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory BoulderPageResponseModel.fromJson(Map<String, dynamic> json) {
    return BoulderPageResponseModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => BoulderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      nextSubCursor: json['nextSubCursor'] as String?,
      hasNext: json['hasNext'] as bool,
      size: json['size'] as int,
    );
  }
}