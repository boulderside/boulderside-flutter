import 'package:boulderside_flutter/home/models/route_page_response_model.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

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

    final response = await _dio.get(
      '/routes',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return RoutePageResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch routes');
    }
  }
}
