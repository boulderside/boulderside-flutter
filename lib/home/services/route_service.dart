import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class RouteService {
  RouteService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<List<RouteModel>> fetchRoutes({int? cursorId, int size = 5, String? searchQuery}) async {
    final queryParams = <String, dynamic>{
      'size': size,
    };

    if (cursorId != null) {
      queryParams['cursor'] = cursorId;
    }

    final response = await _dio.get(
      '/routes',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => RouteModel.fromJson(e)).toList();
      } else {
        final content = data['content'] as List;
        return content.map((e) => RouteModel.fromJson(e)).toList();
      }
    } else {
      throw Exception('Failed to fetch routes');
    }
  }
}
