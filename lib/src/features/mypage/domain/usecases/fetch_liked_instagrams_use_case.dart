import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_instagram_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';

class FetchLikedInstagramsUseCase {
  const FetchLikedInstagramsUseCase(this._repository);

  final MyLikesRepository _repository;

  Future<Result<LikedInstagramPage>> call({int? cursor, int size = 10}) {
    return _repository.fetchLikedInstagrams(cursor: cursor, size: size);
  }
}
