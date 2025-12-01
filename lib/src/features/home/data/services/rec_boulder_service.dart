import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/models/rec_boulder_response_model.dart';
import 'package:dio/dio.dart';

class RecBoulderService {
  RecBoulderService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<Result<RecBoulderResponseModel>> fetchBoulders({
    String boulderSortType = 'LATEST_CREATED',
    int? cursor,
    String? subCursor,
    int size = 5,
  }) async {
    try {
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
        return Result.success(RecBoulderResponseModel.fromJson(data));
      }
      return Result.failure(
        ApiFailure(
          message: '추천 바위를 불러오지 못했습니다.',
          statusCode: response.statusCode,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
