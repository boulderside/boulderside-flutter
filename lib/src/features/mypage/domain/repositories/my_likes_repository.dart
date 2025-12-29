import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_instagram_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_boulder_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_route_page.dart';

abstract class MyLikesRepository {
  Future<Result<LikedRoutePage>> fetchLikedRoutes({int? cursor, int size});

  Future<Result<LikedBoulderPage>> fetchLikedBoulders({int? cursor, int size});

  Future<Result<LikedInstagramPage>> fetchLikedInstagrams({
    int? cursor,
    int size,
  });
}
