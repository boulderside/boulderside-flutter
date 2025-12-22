import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram_page.dart';

abstract class InstagramRepository {
  Future<void> createInstagram({
    required String url,
    required List<int> routeIds,
  });

  Future<Result<InstagramPage>> fetchMyInstagrams({int? cursor, int size = 10});

  Future<Result<void>> deleteInstagram(int instagramId);

  Future<Result<RouteInstagramPage>> fetchInstagramsByRouteId({
    required int routeId,
    int? cursor,
    int size = 10,
  });
}
