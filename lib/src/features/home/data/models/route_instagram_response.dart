import 'package:boulderside_flutter/src/features/home/data/models/instagram_response.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_instagram_response.g.dart';

@JsonSerializable()
class RouteInstagramResponse {
  const RouteInstagramResponse({
    required this.routeInstagramId,
    required this.routeId,
    required this.instagramId,
    required this.instagram,
    this.createdAt,
    this.updatedAt,
  });

  final int routeInstagramId;
  final int routeId;
  final int instagramId;
  final InstagramResponse instagram;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RouteInstagramResponse.fromJson(Map<String, dynamic> json) =>
      _$RouteInstagramResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RouteInstagramResponseToJson(this);

  RouteInstagram toDomain() {
    return RouteInstagram(
      routeInstagramId: routeInstagramId,
      routeId: routeId,
      instagramId: instagramId,
      instagram: instagram.toDomain(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
