import 'package:boulderside_flutter/src/features/mypage/data/models/route_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_page_response.dart';
import 'package:dio/dio.dart';

class RouteCompletionService {
  RouteCompletionService(Dio dio) : _dio = dio;

  final Dio _dio;
  static const String _basePath = '/routes';

  Future<List<RouteCompletionModel>> fetchCompletions({
    int pageSize = 20,
  }) async {
    final List<RouteCompletionModel> completions = <RouteCompletionModel>[];
    int? cursor;
    bool hasNext = true;

    while (hasNext) {
      final page = await fetchCompletionPage(cursor: cursor, size: pageSize);
      completions.addAll(page.content);
      cursor = page.nextCursor;
      hasNext = page.hasNext && cursor != null;
      if (!page.hasNext || page.content.isEmpty) {
        break;
      }
    }

    return completions;
  }

  Future<RouteCompletionPageResponse> fetchCompletionPage({
    int? cursor,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '$_basePath/completions/page',
      queryParameters: {
        'size': size,
        if (cursor != null) 'cursor': cursor,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return RouteCompletionPageResponse.fromJson(data);
      }
    }
    throw Exception('등반 기록을 불러오지 못했습니다.');
  }

  Future<RouteCompletionModel> createCompletion({
    required int routeId,
    required bool completed,
    String? memo,
    List<RouteAttemptHistoryModel> attemptHistories =
        const <RouteAttemptHistoryModel>[],
  }) async {
    final response = await _dio.post(
      '$_basePath/$routeId/completion',
      data: _buildBody(
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      ),
    );
    return _parseSingle(response);
  }

  Future<RouteCompletionModel> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
    List<RouteAttemptHistoryModel> attemptHistories =
        const <RouteAttemptHistoryModel>[],
  }) async {
    final response = await _dio.put(
      '$_basePath/$routeId/completion',
      data: _buildBody(
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      ),
    );
    return _parseSingle(response);
  }

  Future<void> deleteCompletion(int routeId) async {
    final response = await _dio.delete('$_basePath/$routeId/completion');
    if (response.statusCode != 200) {
      throw Exception('등반 기록을 삭제하지 못했습니다.');
    }
  }

  Map<String, dynamic> _buildBody({
    required bool completed,
    String? memo,
    List<RouteAttemptHistoryModel>? attemptHistories,
  }) {
    return <String, dynamic>{
      'completed': completed,
      if (memo != null && memo.trim().isNotEmpty) 'memo': memo.trim(),
      if (attemptHistories != null && attemptHistories.isNotEmpty)
        'attemptHistories':
            attemptHistories.map((history) => history.toJson()).toList(),
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
