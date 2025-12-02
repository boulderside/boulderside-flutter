import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/route_completion_repository.dart';

class FetchRouteCompletionsUseCase {
  const FetchRouteCompletionsUseCase(this._repository);

  final RouteCompletionRepository _repository;

  Future<Result<List<RouteCompletionModel>>> call() {
    return _repository.fetchCompletions();
  }
}
