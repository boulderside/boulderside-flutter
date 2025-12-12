import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/route_completion_repository.dart';

class CreateRouteCompletionUseCase {
  const CreateRouteCompletionUseCase(this._repository);

  final RouteCompletionRepository _repository;

  Future<Result<RouteCompletionModel>> call({
    required int routeId,
    required bool completed,
    String? memo,
    List<RouteAttemptHistoryModel> attemptHistories =
        const <RouteAttemptHistoryModel>[],
  }) {
    return _repository.createCompletion(
      routeId: routeId,
      completed: completed,
      memo: memo,
      attemptHistories: attemptHistories,
    );
  }
}
