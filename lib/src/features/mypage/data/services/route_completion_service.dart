import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:dio/dio.dart';

class RouteCompletionService {
  RouteCompletionService() : _dio = ApiClient.dio;

  final Dio _dio;
  static const String _basePath = '/routes';

  Future<List<RouteCompletionModel>> fetchCompletions() async {
    final response = await _dio.get('$_basePath/completions');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((item) =>
                RouteCompletionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }
    throw Exception('등반 기록을 불러오지 못했습니다.');
  }

  Future<RouteCompletionModel> createCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    final response = await _dio.post(
      '$_basePath/$routeId/completion',
      data: _buildBody(completed: completed, memo: memo),
    );
    return _parseSingle(response);
  }

  Future<RouteCompletionModel> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    final response = await _dio.put(
      '$_basePath/$routeId/completion',
      data: _buildBody(completed: completed, memo: memo),
    );
    return _parseSingle(response);
  }

  Future<void> deleteCompletion(int routeId) async {
    final response = await _dio.delete('$_basePath/$routeId/completion');
    if (response.statusCode != 200) {
      throw Exception('등반 기록을 삭제하지 못했습니다.');
    }
  }

  Map<String, dynamic> _buildBody({required bool completed, String? memo}) {
    return <String, dynamic>{
      'completed': completed,
      if (memo != null && memo.trim().isNotEmpty) 'memo': memo.trim(),
    };
  }

  RouteCompletionModel _parseSingle(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return RouteCompletionModel.fromJson(data);
      }
    }
    throw Exception('등반 기록 요청이 실패했습니다.');
  }
}
