import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/like_repository.dart';

class ToggleInstagramLikeUseCase {
  const ToggleInstagramLikeUseCase(this._repository);

  final LikeRepository _repository;

  Future<LikeToggleResult> call(int instagramId) {
    return _repository.toggleInstagramLike(instagramId);
  }
}
