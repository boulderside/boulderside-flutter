import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  LikeRepositoryImpl(this._service);

  final LikeService _service;

  @override
  Future<LikeToggleResult> toggleBoulderLike(int boulderId) {
    return _service.toggleBoulderLike(boulderId);
  }

  @override
  Future<LikeToggleResult> toggleRouteLike(int routeId) {
    return _service.toggleRouteLike(routeId);
  }
}
