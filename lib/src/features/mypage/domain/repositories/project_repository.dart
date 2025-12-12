import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';

abstract class ProjectRepository {
  Future<Result<List<ProjectModel>>> fetchProjects({bool? isCompleted});

  Future<Result<ProjectModel>> createProject({
    required int routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories,
  });

  Future<Result<ProjectModel>> updateProject({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories,
  });

  Future<Result<void>> deleteProject(int projectId);

  Future<Result<ProjectModel?>> fetchProjectByRouteId(int routeId);
}
