import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/route_completion_service.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/repositories/route_completion_repository.dart';

class RouteCompletionRepositoryImpl implements RouteCompletionRepository {
  RouteCompletionRepositoryImpl(this._service);

  final RouteCompletionService _service;

  @override
  Future<Result<List<RouteCompletionModel>>> fetchCompletions() async {
    try {
      final completions = await _service.fetchCompletions();
      return Result.success(completions);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<RouteCompletionModel>> createCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    try {
      final completion = await _service.createCompletion(routeId: routeId, completed: completed, memo: memo);
      return Result.success(completion);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<RouteCompletionModel>> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    try {
      final completion = await _service.updateCompletion(routeId: routeId, completed: completed, memo: memo);
      return Result.success(completion);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<void>> deleteCompletion(int routeId) async {
    try {
      await _service.deleteCompletion(routeId);
      return Result.success(null);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
