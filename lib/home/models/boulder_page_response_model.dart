import 'package:boulderside_flutter/home/models/boulder_model.dart';

class BoulderPageResponseModel {
  final List<BoulderModel> content;
  final int? nextCursor;
  final int? nextLikeCount;
  final bool hasNext;
  final int size;

  BoulderPageResponseModel({
    required this.content,
    required this.nextCursor,
    required this.nextLikeCount,
    required this.hasNext,
    required this.size,
  });

  factory BoulderPageResponseModel.fromJson(Map<String, dynamic> json) {
    return BoulderPageResponseModel(
      content: (json['content'] as List)
          .map((e) => BoulderModel.fromJson(e))
          .toList(),
      nextCursor: json['nextCursor'],
      nextLikeCount: json['nextLikeCount'],
      hasNext: json['hasNext'],
      size: json['size'],
    );
  }
}