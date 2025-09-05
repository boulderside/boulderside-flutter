import 'package:boulderside_flutter/home/models/boulder_page_response_model.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class BoulderService {
  BoulderService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<BoulderPageResponseModel> fetchBoulders({
    String boulderSortType = 'LATEST_CREATED',
    int? cursor,
    String? subCursor,
    int size = 5,
  }) async {
    final queryParameters = <String, dynamic>{
      'boulderSortType': boulderSortType,
      'size': size,
    };
    
    if (cursor != null) {
      queryParameters['cursor'] = cursor;
    }
    if (subCursor != null) {
      queryParameters['subCursor'] = subCursor;
    }

    final response = await _dio.get(
      '/boulders',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoulderPageResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch boulders');
    }
  }
}
