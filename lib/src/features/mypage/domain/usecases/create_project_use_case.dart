import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<ProjectModel>> call({
    required int routeId,
    required bool completed,
    String? memo,
    List<ProjectAttemptHistoryModel> attemptHistories =
        const <ProjectAttemptHistoryModel>[],
  }) {
    return _repository.createProject(
      routeId: routeId,
      completed: completed,
      memo: memo,
      attemptHistories: attemptHistories,
    );
  }
}
