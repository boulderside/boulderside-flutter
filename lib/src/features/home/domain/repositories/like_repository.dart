import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';

abstract class LikeRepository {
  Future<LikeToggleResult> toggleRouteLike(int routeId);
  Future<LikeToggleResult> toggleBoulderLike(int boulderId);
  Future<LikeToggleResult> toggleInstagramLike(int instagramId);
}
