import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/like_repository.dart';

class ToggleBoulderLikeUseCase {
  const ToggleBoulderLikeUseCase(this._repository);

  final LikeRepository _repository;

  Future<LikeToggleResult> call(int boulderId) {
    return _repository.toggleBoulderLike(boulderId);
  }
}
