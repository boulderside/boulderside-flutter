import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/home/data/models/rec_boulder_response_model.dart';
import 'package:dio/dio.dart';

class RecBoulderService {
  RecBoulderService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<RecBoulderResponseModel> fetchBoulders({
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
      return RecBoulderResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch boulders');
    }
  }
}
