import 'package:boulderside_flutter/src/features/community/data/models/user_info.dart';

class InstagramDetail {
  const InstagramDetail({
    required this.id,
    required this.url,
    required this.userInfo,
    required this.routes,
    required this.likeCount,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String url;
  final UserInfo userInfo;
  final List<InstagramRouteInfo> routes;
  final int likeCount;
  final bool liked;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class InstagramRouteInfo {
  const InstagramRouteInfo({
    required this.routeId,
    required this.name,
    required this.boulderName,
  });

  final int routeId;
  final String name;
  final String boulderName;
}
