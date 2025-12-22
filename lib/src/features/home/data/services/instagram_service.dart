import 'package:boulderside_flutter/src/features/home/data/models/instagram_page_response.dart';
import 'package:boulderside_flutter/src/features/home/data/models/route_instagram_page_response.dart';
import 'package:dio/dio.dart';

class InstagramService {
  InstagramService(Dio dio) : _dio = dio;

  final Dio _dio;
  static const String _basePath = '/instagrams';

  Future<void> createInstagram({
    required String url,
    required List<int> routeIds,
  }) async {
    final response = await _dio.post(
      _basePath,
      data: {'url': url, 'routeIds': routeIds},
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('인스타그램 등록에 실패했습니다.');
    }
  }

  Future<InstagramPageResponse> fetchMyInstagrams({
    int? cursor,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '$_basePath/my',
      queryParameters: {if (cursor != null) 'cursor': cursor, 'size': size},
    );

    if (response.statusCode != 200) {
      throw Exception('인스타그램 목록 조회에 실패했습니다.');
    }

    return InstagramPageResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteInstagram(int instagramId) async {
    final response = await _dio.delete('$_basePath/$instagramId');

    if (response.statusCode != 200) {
      throw Exception('인스타그램 삭제에 실패했습니다.');
    }
  }

  Future<void> updateInstagram({
    required int instagramId,
    required String url,
    required List<int> routeIds,
  }) async {
    final response = await _dio.put(
      '$_basePath/$instagramId',
      data: {'url': url, 'routeIds': routeIds},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('인스타그램 수정에 실패했습니다.');
    }
  }

  Future<RouteInstagramPageResponse> fetchInstagramsByRouteId({
    required int routeId,
    int? cursor,
    int size = 10,
  }) async {
    final response = await _dio.get(
      _basePath,
      queryParameters: {
        'routeId': routeId,
        if (cursor != null) 'cursor': cursor,
        'size': size,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('루트 인스타그램 목록 조회에 실패했습니다.');
    }

    return RouteInstagramPageResponse.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
