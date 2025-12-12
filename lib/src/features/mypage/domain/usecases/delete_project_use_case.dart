import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class DeleteProjectUseCase {
  const DeleteProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<void>> call(int projectId) {
    return _repository.deleteProject(projectId);
  }
}
