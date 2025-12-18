import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/project_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/project_sort_type.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl(this._service);

  final ProjectService _service;

  @override
  Future<Result<List<ProjectModel>>> fetchProjects({
    bool? isCompleted,
    ProjectSortType sortType = ProjectSortType.latestUpdated,
  }) async {
    try {
      final projects = await _service.fetchProjects(
        isCompleted: isCompleted,
        sortType: sortType,
      );
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
    List<ProjectSessionModel> sessions = const <ProjectSessionModel>[],
  }) async {
    try {
      final project = await _service.createProject(
        routeId: routeId,
        completed: completed,
        memo: memo,
        sessions: sessions,
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
    List<ProjectSessionModel> sessions = const <ProjectSessionModel>[],
  }) async {
    try {
      final project = await _service.updateProject(
        projectId: projectId,
        completed: completed,
        memo: memo,
        sessions: sessions,
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
