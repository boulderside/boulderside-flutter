import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_likes_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_boulder_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_instagram_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_route_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';

class MyLikesRepositoryImpl implements MyLikesRepository {
  MyLikesRepositoryImpl(this._service);

  final MyLikesService _service;

  @override
  Future<Result<LikedRoutePage>> fetchLikedRoutes({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchLikedRoutes(
        cursor: cursor,
        size: size,
      );
      return Result.success(
        LikedRoutePage(
          items: response.content,
          nextCursor: response.nextCursor,
          hasNext: response.hasNext,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<LikedBoulderPage>> fetchLikedBoulders({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchLikedBoulders(
        cursor: cursor,
        size: size,
      );
      return Result.success(
        LikedBoulderPage(
          items: response.content,
          nextCursor: response.nextCursor,
          hasNext: response.hasNext,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<LikedInstagramPage>> fetchLikedInstagrams({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchLikedInstagrams(
        cursor: cursor,
        size: size,
      );
      return Result.success(
        LikedInstagramPage(
          items: response.content,
          nextCursor: response.nextCursor,
          hasNext: response.hasNext,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
