import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/project_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._service);

  final ProjectService _service;

  @override
  Future<Result<List<ProjectModel>>> fetchProjects() async {
    try {
      final projects = await _service.fetchProjects();
      return Result.success(projects);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<ProjectModel>> createProject({
    required int routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    try {
      final project = await _service.createProject(
        routeId: routeId,
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      );
      return Result.success(project);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<ProjectModel>> updateProject({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) async {
    try {
      final project = await _service.updateProject(
        projectId: projectId,
        completed: completed,
        memo: memo,
        attemptHistories: attemptHistories,
      );
      return Result.success(project);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<void>> deleteProject(int projectId) async {
    try {
      await _service.deleteProject(projectId);
      return Result.success(null);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<ProjectModel?>> fetchProjectByRouteId(int routeId) async {
    try {
      final project = await _service.fetchProjectByRouteId(routeId);
      return Result.success(project);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
