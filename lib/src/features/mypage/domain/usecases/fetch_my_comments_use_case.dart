import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_comment_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_comments_repository.dart';

class FetchMyCommentsUseCase {
  const FetchMyCommentsUseCase(this._repository);

  final MyCommentsRepository _repository;

  Future<Result<MyCommentPage>> call({
    int? cursor,
    int size = 10,
    String? domainType,
  }) {
    return _repository.fetchMyComments(
      cursor: cursor,
      size: size,
      domainType: domainType,
    );
  }
}
