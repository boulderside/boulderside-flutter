import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_page_response.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/project_sort_type.dart';
import 'package:dio/dio.dart';

class ProjectService {
  ProjectService(Dio dio) : _dio = dio;

  final Dio _dio;
  static const String _basePath = '/projects';

  Future<List<ProjectModel>> fetchProjects({
    int pageSize = 20,
    bool? isCompleted,
    ProjectSortType sortType = ProjectSortType.latestUpdated,
  }) async {
    final List<ProjectModel> projects = <ProjectModel>[];
    int? cursor;
    bool hasNext = true;

    while (hasNext) {
      final page = await fetchProjectPage(
        cursor: cursor,
        size: pageSize,
        isCompleted: isCompleted,
        sortType: sortType,
      );
      projects.addAll(page.content);
      cursor = page.nextCursor;
      hasNext = page.hasNext && cursor != null;
      if (!page.hasNext || page.content.isEmpty) {
        break;
      }
    }

    return projects;
  }

  Future<ProjectPageResponse> fetchProjectPage({
    int? cursor,
    int size = 10,
    bool? isCompleted,
    ProjectSortType sortType = ProjectSortType.latestUpdated,
  }) async {
    final response = await _dio.get(
      '$_basePath/page',
      queryParameters: {
        'size': size,
        'sortType': sortType.value,
        if (cursor != null) 'cursor': cursor,
        if (isCompleted != null) 'isCompleted': isCompleted,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return ProjectPageResponse.fromJson(data);
      }
    }
    throw Exception('프로젝트를 불러오지 못했습니다.');
  }

  Future<ProjectModel?> fetchProjectByRouteId(int routeId) async {
    try {
      final response = await _dio.get(
        _basePath,
        queryParameters: {'routeId': routeId},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return ProjectModel.fromJson(data);
        }
      }
      return null;
    } on DioException catch (error) {
      final status = error.response?.statusCode ?? 500;
      if (status == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<ProjectModel> createProject({
    required int routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    final response = await _dio.post(
      _basePath,
      data: _buildBody(
        routeId: routeId,
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      ),
    );
    return _parseSingle(response);
  }

  Future<ProjectModel> updateProject({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    final response = await _dio.put(
      '$_basePath/$projectId',
      data: _buildBody(
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      ),
    );
    return _parseSingle(response);
  }

  Future<void> deleteProject(int projectId) async {
    final response = await _dio.delete('$_basePath/$projectId');
    final status = response.statusCode ?? 500;
    if (status < 200 || status >= 300) {
      throw Exception('프로젝트를 삭제하지 못했습니다.');
    }
  }

  Map<String, dynamic> _buildBody({
    int? routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel>? attemptHistories,
  }) {
    return <String, dynamic>{
      if (routeId != null) 'routeId': routeId,
      'completed': completed,
      if (memo != null && memo.trim().isNotEmpty) 'memo': memo.trim(),
      if (attemptHistories != null && attemptHistories.isNotEmpty)
        'attemptHistories': attemptHistories
            .map((history) => history.toJson())
            .toList(),
    };
  }

  ProjectModel _parseSingle(Response<dynamic> response) {
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return ProjectModel.fromJson(data);
      }
    }
    throw Exception('프로젝트 요청이 실패했습니다.');
  }
}
