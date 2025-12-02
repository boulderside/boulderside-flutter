import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/boulder_dto.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';
import 'package:dio/dio.dart';

class RecBoulderService {
  RecBoulderService(Dio dio) : _dio = dio;
  final Dio _dio;

  Future<RecBoulderPage> fetchBoulders({
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

    if (response.statusCode != 200) {
      throw ApiFailure(
        message: '추천 바위를 불러오지 못했습니다.',
        statusCode: response.statusCode,
      );
    }
    final data = response.data['data'] as Map<String, dynamic>;
    final items = (data['content'] as List<dynamic>)
        .map((e) => BoulderDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
    return RecBoulderPage(
      items: items,
      nextCursor: data['nextCursor'] as int?,
      nextSubCursor: data['nextSubCursor'] as String?,
      hasNext: data['hasNext'] as bool? ?? false,
    );
  }
}
