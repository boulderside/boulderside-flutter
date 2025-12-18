import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<ProjectModel>> call({
    required int projectId,
    required bool completed,
    String? memo,
    List<ProjectSessionModel> sessions = const <ProjectSessionModel>[],
  }) {
    return _repository.updateProject(
      projectId: projectId,
      completed: completed,
      memo: memo,
      sessions: sessions,
    );
  }
}
