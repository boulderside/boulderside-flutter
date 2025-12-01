import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/home/data/models/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/boulder_page_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  Future<List<BoulderModel>> fetchAllBoulders() async {
    debugPrint('[BoulderService] GET /boulders/all 요청');
    final response = await _dio.get('/boulders/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final result = data
          .map((e) => BoulderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[BoulderService] /boulders/all 응답 (${result.length}건)');
      for (final boulder in result) {
        debugPrint(
          '  • id=${boulder.id} name=${boulder.name} '
          '(${boulder.latitude}, ${boulder.longitude})',
        );
      }
      return result;
    } else {
      debugPrint(
        '[BoulderService] /boulders/all 실패 status=${response.statusCode}',
      );
      throw Exception('Failed to fetch boulders');
    }
  }
}
