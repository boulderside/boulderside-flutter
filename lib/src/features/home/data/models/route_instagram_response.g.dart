// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_instagram_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteInstagramResponse _$RouteInstagramResponseFromJson(
  Map<String, dynamic> json,
) => RouteInstagramResponse(
  routeInstagramId: (json['routeInstagramId'] as num).toInt(),
  routeId: (json['routeId'] as num).toInt(),
  instagramId: (json['instagramId'] as num).toInt(),
  instagram: InstagramResponse.fromJson(
    json['instagram'] as Map<String, dynamic>,
  ),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RouteInstagramResponseToJson(
  RouteInstagramResponse instance,
) => <String, dynamic>{
  'routeInstagramId': instance.routeInstagramId,
  'routeId': instance.routeId,
  'instagramId': instance.instagramId,
  'instagram': instance.instagram,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
