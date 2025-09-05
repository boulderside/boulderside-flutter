import 'package:boulderside_flutter/home/models/boulder_model.dart';

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
      content: (json['content'] as List? ?? [])
          .map((e) => BoulderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: _parseToInt(json['nextCursor']),
      nextSubCursor: json['nextSubCursor'],
      hasNext: json['hasNext'] ?? false,
      size: _parseToInt(json['size']) ?? 0,
    );
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}