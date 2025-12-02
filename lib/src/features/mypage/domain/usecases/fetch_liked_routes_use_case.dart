import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_route_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/my_likes_repository.dart';

class FetchLikedRoutesUseCase {
  const FetchLikedRoutesUseCase(this._repository);

  final MyLikesRepository _repository;

  Future<Result<LikedRoutePage>> call({int? cursor, int size = 10}) {
    return _repository.fetchLikedRoutes(cursor: cursor, size: size);
  }
}
