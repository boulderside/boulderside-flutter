import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:dio/dio.dart';

class MyLikesService {
  MyLikesService() : _dio = ApiClient.dio;

  final Dio _dio;

  Future<List<RouteModel>> fetchLikedRoutes() async {
    final response = await _dio.get('/routes/likes');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((item) => RouteModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }
    throw Exception('좋아요한 루트를 불러오지 못했습니다.');
  }

  Future<List<BoulderModel>> fetchLikedBoulders() async {
    final response = await _dio.get('/boulders/likes');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((item) => BoulderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }
    throw Exception('좋아요한 바위를 불러오지 못했습니다.');
  }
}
