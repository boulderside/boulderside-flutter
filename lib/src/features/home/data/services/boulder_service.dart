import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/boulder_dto.dart';
import 'package:boulderside_flutter/src/features/home/data/models/boulder_page_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BoulderService {
  BoulderService(Dio dio) : _dio = dio;
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
    }
    throw ApiFailure(
      message: '바위 목록을 불러오지 못했습니다.',
      statusCode: response.statusCode,
    );
  }

  Future<List<BoulderModel>> fetchAllBoulders() async {
    debugPrint('[BoulderService] GET /boulders/all 요청');
    final response = await _dio.get('/boulders/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final result = data
          .map((e) => BoulderDto.fromJson(e as Map<String, dynamic>).toDomain())
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

  Future<List<BoulderModel>> fetchBouldersInBounds({
    required double southWestLat,
    required double southWestLng,
    required double northEastLat,
    required double northEastLng,
    int limit = 200,
  }) async {
    final queryParameters = <String, dynamic>{
      'southWestLat': southWestLat,
      'southWestLng': southWestLng,
      'northEastLat': northEastLat,
      'northEastLng': northEastLng,
      'limit': limit,
    };

    final response = await _dio.get(
      '/boulders/within-bounds',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => BoulderDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    }
    throw Exception('지도용 바위 목록을 불러오지 못했습니다.');
  }
}
