import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class FetchProjectsUseCase {
  const FetchProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<List<ProjectModel>>> call() {
    return _repository.fetchProjects();
  }
}
