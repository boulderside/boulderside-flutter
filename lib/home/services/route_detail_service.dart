import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/home/models/route_detail_model.dart';
import 'package:dio/dio.dart';

class RouteDetailService {
  RouteDetailService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<RouteDetailModel> fetchDetail(int routeId) async {
    final response = await _dio.get('/routes/$routeId');
    if (response.statusCode == 200) {
      final raw = response.data['data'] ?? response.data;
      if (raw is Map<String, dynamic>) {
        return RouteDetailModel.fromJson(raw);
      }
    }
    throw Exception('루트 정보를 불러오지 못했습니다.');
  }
}
