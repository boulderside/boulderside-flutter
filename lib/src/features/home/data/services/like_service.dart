import 'package:dio/dio.dart';

class LikeToggleResult {
  const LikeToggleResult({
    this.routeId,
    this.boulderId,
    this.instagramId,
    this.liked,
    this.likeCount,
  });

  final int? routeId;
  final int? boulderId;
  final int? instagramId;
  final bool? liked;
  final int? likeCount;

  int? get targetId => routeId ?? boulderId ?? instagramId;
  bool get isRoute => routeId != null;
  bool get isBoulder => boulderId != null;
  bool get isInstagram => instagramId != null;

  factory LikeToggleResult.fromJson(Map<String, dynamic> json) {
    return LikeToggleResult(
      routeId: json['routeId'] as int?,
      boulderId: json['boulderId'] as int?,
      instagramId: json['instagramId'] as int?,
      liked: json['liked'] ?? json['isLiked'] as bool?,
      likeCount: json['likeCount'] ?? json['totalLikes'] as int?,
    );
  }
}

class LikeService {
  LikeService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<LikeToggleResult> toggleRouteLike(int routeId) async {
    final response = await _dio.post('/routes/$routeId/likes/toggle');
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
    final response = await _dio.post('/boulders/$boulderId/likes/toggle');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikeToggleResult.fromJson(data);
      }
      return const LikeToggleResult();
    }
    throw Exception('바위 좋아요를 변경하지 못했습니다.');
  }

  Future<LikeToggleResult> toggleInstagramLike(int instagramId) async {
    final response = await _dio.post('/instagrams/$instagramId/likes/toggle');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikeToggleResult.fromJson(data);
      }
      return const LikeToggleResult();
    }
    throw Exception('인스타그램 좋아요를 변경하지 못했습니다.');
  }
}
