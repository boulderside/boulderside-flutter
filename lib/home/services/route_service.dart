import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/models/route_page_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RouteService {
  RouteService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<RoutePageResponseModel> fetchRoutes({
    int? cursor,
    String? subCursor,
    int size = 5,
    String routeSortType = 'DIFFICULTY',
    String? searchQuery,
  }) async {
    final queryParams = <String, dynamic>{
      'size': size,
      'routeSortType': routeSortType,
    };

    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    if (subCursor != null) {
      queryParams['subCursor'] = subCursor;
    }

    final response = await _dio.get('/routes', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return RoutePageResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch routes');
    }
  }

  Future<List<RouteModel>> fetchAllRoutes() async {
    debugPrint('[RouteService] GET /routes/all 요청');
    final response = await _dio.get('/routes/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final result = data
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[RouteService] /routes/all 응답 (${result.length}건)');
      return result;
    } else {
      debugPrint('[RouteService] /routes/all 실패 status=${response.statusCode}');
      throw Exception('Failed to fetch routes');
    }
  }
}
