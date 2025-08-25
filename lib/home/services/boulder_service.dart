import 'package:boulderside_flutter/home/models/boulder_page_response_model.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class BoulderService {
  // BoulderService 객체가 만들어질 때 본문 실행 전 final 필드인 _dio를 단 한번 초기화
  BoulderService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<BoulderPageResponseModel> fetchBoulders({
    String sortType = 'LATEST',
    int? cursor,
    int? cursorLikeCount,
    int? size,
  }) async {
    final response = await _dio.get(
      '/boulders',
      queryParameters: {
        'sortType': sortType,
        'cursor': cursor,
        'cursorLikeCount': cursorLikeCount,
        'size': size,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoulderPageResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch boulders');
    }
  }
}
