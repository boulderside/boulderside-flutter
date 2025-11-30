import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class LikeToggleResult {
  const LikeToggleResult({this.liked, this.likeCount});

  final bool? liked;
  final int? likeCount;

  factory LikeToggleResult.fromJson(Map<String, dynamic> json) {
    return LikeToggleResult(
      liked: json['liked'] ?? json['isLiked'] as bool?,
      likeCount: json['likeCount'] ?? json['totalLikes'] as int?,
    );
  }
}

class LikeService {
  LikeService() : _dio = ApiClient.dio;

  final Dio _dio;

  Future<LikeToggleResult> toggleRouteLike(int routeId) async {
    final response = await _dio.post('/likes/routes/$routeId/toggle');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikeToggleResult.fromJson(data);
      }
      return const LikeToggleResult();
    }
    throw Exception('루트 좋아요를 변경하지 못했습니다.');
  }

  Future<LikeToggleResult> toggleBoulderLike(int boulderId) async {
    final response = await _dio.post('/likes/boulders/$boulderId/toggle');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikeToggleResult.fromJson(data);
      }
      return const LikeToggleResult();
    }
    throw Exception('바위 좋아요를 변경하지 못했습니다.');
  }
}
