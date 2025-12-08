import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';

abstract class RouteCompletionRepository {
  Future<Result<List<RouteCompletionModel>>> fetchCompletions();

  Future<Result<RouteCompletionModel>> createCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  });

  Future<Result<RouteCompletionModel>> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  });

  Future<Result<void>> deleteCompletion(int routeId);
}
