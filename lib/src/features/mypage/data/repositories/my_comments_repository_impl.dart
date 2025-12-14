import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_comments_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_comment_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_comments_repository.dart';

class MyCommentsRepositoryImpl implements MyCommentsRepository {
  MyCommentsRepositoryImpl(this._service);

  final MyCommentsService _service;

  @override
  Future<Result<MyCommentPage>> fetchMyComments({
    int? cursor,
    int size = 10,
    String? domainType,
  }) async {
    try {
      final response = await _service.fetchMyComments(
        cursor: cursor,
        size: size,
        domainType: domainType,
      );
      return Result.success(
        MyCommentPage(
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
