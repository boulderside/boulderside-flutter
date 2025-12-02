import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/route_completion_repository.dart';

class DeleteRouteCompletionUseCase {
  const DeleteRouteCompletionUseCase(this._repository);

  final RouteCompletionRepository _repository;

  Future<Result<void>> call(int routeId) {
    return _repository.deleteCompletion(routeId);
  }
}
