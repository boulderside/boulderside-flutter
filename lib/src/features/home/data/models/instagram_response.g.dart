// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstagramResponse _$InstagramResponseFromJson(Map<String, dynamic> json) =>
    InstagramResponse(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      routeIds: (json['routeIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$InstagramResponseToJson(InstagramResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'routeIds': instance.routeIds,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
