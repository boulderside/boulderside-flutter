import 'package:boulderside_flutter/home/models/rec_boulder_model.dart';

class RecBoulderResponseModel {
  final List<RecBoulderModel> content;
  final int? nextCursor;
  final int? nextLikeCount;
  final bool hasNext;
  final int size;

  RecBoulderResponseModel({
    required this.content,
    required this.nextCursor,
    required this.nextLikeCount,
    required this.hasNext,
    required this.size,
  });

  factory RecBoulderResponseModel.fromJson(Map<String, dynamic> json) {
    return RecBoulderResponseModel(
      content: (json['content'] as List)
          .map((e) => RecBoulderModel.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'],
      nextLikeCount: json['nextLikeCount'],
      hasNext: json['hasNext'],
      size: json['size'],
    );
  }
}
