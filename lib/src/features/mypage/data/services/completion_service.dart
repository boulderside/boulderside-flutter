import 'package:boulderside_flutter/src/features/mypage/data/models/completion_page_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_request.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:dio/dio.dart';

class CompletionService {
  CompletionService(this._dio);

  final Dio _dio;
  static const String _basePath = '/completions';

  Future<CompletionResponse?> fetchCompletionByRoute(int routeId) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {'routeId': routeId},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        if (data != null) {
          return CompletionResponse.fromJson(
            Map<String, dynamic>.from(data as Map),
          );
        }
      }
      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<CompletionResponse> fetchCompletion(int completionId) async {
    final response = await _dio.get('$_basePath/$completionId');
    final data = response.data['data'] ?? response.data;
    return CompletionResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<CompletionResponse> createCompletion(CompletionRequest request) async {
    final response = await _dio.post(_basePath, data: request.toJson());
    final data = response.data['data'] ?? response.data;
    return CompletionResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<CompletionResponse> updateCompletion({
    required int completionId,
    required CompletionRequest request,
  }) async {
    final response = await _dio.put(
      '$_basePath/$completionId',
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;
    return CompletionResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> deleteCompletion(int completionId) async {
    await _dio.delete('$_basePath/$completionId');
  }

  Future<CompletionPageResponse> fetchCompletionPage({
    int? cursor,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '$_basePath/page',
      queryParameters: {'size': size, if (cursor != null) 'cursor': cursor},
    );
    final data = response.data['data'] ?? response.data;
    return CompletionPageResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }
}
