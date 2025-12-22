// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstagramResponse _$InstagramResponseFromJson(Map<String, dynamic> json) =>
    InstagramResponse(
      id: (json['instagramId'] as num).toInt(),
      url: json['url'] as String,
      routeIds: (json['routeIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InstagramResponseToJson(InstagramResponse instance) =>
    <String, dynamic>{
      'instagramId': instance.id,
      'url': instance.url,
      'routeIds': instance.routeIds,
      'userId': instance.userId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
