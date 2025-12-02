import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_mate_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_posts_repository.dart';

class FetchMyMatePostsUseCase {
  const FetchMyMatePostsUseCase(this._repository);

  final MyPostsRepository _repository;

  Future<Result<MyMatePostsPage>> call({int? cursor, int size = 10}) {
    return _repository.fetchMyMatePosts(cursor: cursor, size: size);
  }
}
