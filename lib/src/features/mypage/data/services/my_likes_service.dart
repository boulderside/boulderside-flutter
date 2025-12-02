import 'package:boulderside_flutter/src/features/mypage/data/models/liked_page_response.dart';
import 'package:dio/dio.dart';

class MyLikesService {
  MyLikesService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<LikedRoutePageResponse> fetchLikedRoutes({int? cursor, int size = 10}) async {
    final response = await _dio.get(
      '/likes/routes',
      queryParameters: {'size': size, if (cursor != null) 'cursor': cursor},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikedRoutePageResponse.fromJson(data);
      }
    }
    throw Exception('좋아요한 루트를 불러오지 못했습니다.');
  }

  Future<LikedBoulderPageResponse> fetchLikedBoulders({int? cursor, int size = 10}) async {
    final response = await _dio.get(
      '/likes/boulders',
      queryParameters: {'size': size, if (cursor != null) 'cursor': cursor},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return LikedBoulderPageResponse.fromJson(data);
      }
    }
    throw Exception('좋아요한 바위를 불러오지 못했습니다.');
  }

  Future<void> toggleRouteLike(int routeId) async {
    final response = await _dio.post('/likes/routes/$routeId/toggle');
    if (response.statusCode != 200) {
      throw Exception('루트 좋아요를 변경하지 못했습니다.');
    }
  }

  Future<void> toggleBoulderLike(int boulderId) async {
    final response = await _dio.post('/likes/boulders/$boulderId/toggle');
    if (response.statusCode != 200) {
      throw Exception('바위 좋아요를 변경하지 못했습니다.');
    }
  }
}
