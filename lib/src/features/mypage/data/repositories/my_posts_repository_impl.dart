import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_posts_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_board_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_mate_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_posts_repository.dart';

class MyPostsRepositoryImpl implements MyPostsRepository {
  MyPostsRepositoryImpl(this._service);

  final MyPostsService _service;

  @override
  Future<Result<MyBoardPostsPage>> fetchMyBoardPosts({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchMyBoardPosts(
        cursor: cursor,
        size: size,
      );
      return Result.success(
        MyBoardPostsPage(
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
  Future<Result<MyMatePostsPage>> fetchMyMatePosts({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchMyMatePosts(
        cursor: cursor,
        size: size,
      );
      return Result.success(
        MyMatePostsPage(
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
