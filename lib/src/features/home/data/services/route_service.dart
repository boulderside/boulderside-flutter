import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/route_dto.dart';
import 'package:boulderside_flutter/src/features/home/data/models/route_page_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RouteService {
  RouteService(Dio dio) : _dio = dio;
  final Dio _dio;

  Future<Result<RoutePageResponseModel>> fetchRoutes({
    int? cursor,
    String? subCursor,
    int size = 5,
    String routeSortType = 'DIFFICULTY',
    String? searchQuery,
  }) async {
    try {
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
        return Result.success(RoutePageResponseModel.fromJson(data));
      }
      return Result.failure(
        ApiFailure(
          message: '루트 목록을 불러오지 못했습니다.',
          statusCode: response.statusCode,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  Future<List<RouteModel>> fetchAllRoutes() async {
    debugPrint('[RouteService] GET /routes/all 요청');
    final response = await _dio.get('/routes/all');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      final result = data
          .map((e) => RouteDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
      debugPrint('[RouteService] /routes/all 응답 (${result.length}건)');
      return result;
    } else {
      debugPrint('[RouteService] /routes/all 실패 status=${response.statusCode}');
      throw Exception('Failed to fetch routes');
    }
  }
}
