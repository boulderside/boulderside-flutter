import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_board_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_posts_repository.dart';

class FetchMyBoardPostsUseCase {
  const FetchMyBoardPostsUseCase(this._repository);

  final MyPostsRepository _repository;

  Future<Result<MyBoardPostsPage>> call({int? cursor, int size = 10}) {
    return _repository.fetchMyBoardPosts(cursor: cursor, size: size);
  }
}
