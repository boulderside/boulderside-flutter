// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instagram_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstagramResponse _$InstagramResponseFromJson(
  Map<String, dynamic> json,
) => InstagramResponse(
  id: (json['instagramId'] as num).toInt(),
  url: json['url'] as String,
  routes:
      (json['routes'] as List<dynamic>?)
          ?.map(
            (e) =>
                InstagramRouteInfoResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  routeIds:
      (json['routeIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  likeCount: ((json['likeCount'] ?? json['totalLikes']) as num?)?.toInt() ?? 0,
  liked: ((json['liked'] ?? json['isLiked']) as bool?) ?? false,
  userInfo: UserInfo.fromJson(
    (json['userInfo'] as Map<String, dynamic>? ??
        {'id': 0, 'nickname': '', 'profileImageUrl': null}),
  ),
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
      'routes': instance.routes.map((e) => e.toJson()).toList(),
      'routeIds': instance.routeIds,
      'likeCount': instance.likeCount,
      'liked': instance.liked,
      'userInfo': instance.userInfo.toJson(),
      'userId': instance.userId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

InstagramRouteInfoResponse _$InstagramRouteInfoResponseFromJson(
  Map<String, dynamic> json,
) => InstagramRouteInfoResponse(
  routeId: (json['routeId'] as num).toInt(),
  name: json['name'] as String? ?? '',
  boulderName: json['boulderName'] as String? ?? '',
);

Map<String, dynamic> _$InstagramRouteInfoResponseToJson(
  InstagramRouteInfoResponse instance,
) => <String, dynamic>{
  'routeId': instance.routeId,
  'name': instance.name,
  'boulderName': instance.boulderName,
};
