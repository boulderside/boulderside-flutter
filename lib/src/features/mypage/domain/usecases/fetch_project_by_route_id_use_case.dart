import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/project_repository.dart';

class FetchProjectByRouteIdUseCase {
  const FetchProjectByRouteIdUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<ProjectModel?>> call(int routeId) {
    return _repository.fetchProjectByRouteId(routeId);
  }
}
