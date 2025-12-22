import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:json_annotation/json_annotation.dart';

part 'instagram_response.g.dart';

@JsonSerializable()
class InstagramResponse {
  const InstagramResponse({
    required this.id,
    required this.url,
    required this.routeIds,
    this.createdAt,
    this.updatedAt,
    this.userId,
  });

  @JsonKey(name: 'instagramId')
  final int id;
  final String url;
  final List<int> routeIds;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory InstagramResponse.fromJson(Map<String, dynamic> json) =>
      _$InstagramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InstagramResponseToJson(this);

  Instagram toDomain() {
    return Instagram(
      id: id,
      url: url,
      routeIds: routeIds,
      createdAt: createdAt,
    );
  }
}
