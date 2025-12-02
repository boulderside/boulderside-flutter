import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_boulder_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';

class FetchLikedBouldersUseCase {
  const FetchLikedBouldersUseCase(this._repository);

  final MyLikesRepository _repository;

  Future<Result<LikedBoulderPage>> call({int? cursor, int size = 10}) {
    return _repository.fetchLikedBoulders(cursor: cursor, size: size);
  }
}
