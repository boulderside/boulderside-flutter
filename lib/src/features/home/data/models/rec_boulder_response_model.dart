import 'package:boulderside_flutter/src/features/home/data/models/rec_boulder_model.dart';

class RecBoulderResponseModel {
  final List<RecBoulderModel> content;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final int size;

  RecBoulderResponseModel({
    required this.content,
    required this.nextCursor,
    required this.nextSubCursor,
    required this.hasNext,
    required this.size,
  });

  factory RecBoulderResponseModel.fromJson(Map<String, dynamic> json) {
    return RecBoulderResponseModel(
      content: (json['content'] as List<dynamic>)
          .map((e) => RecBoulderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      nextSubCursor: json['nextSubCursor'] as String?,
      hasNext: json['hasNext'] as bool,
      size: json['size'] as int,
    );
  }
}
