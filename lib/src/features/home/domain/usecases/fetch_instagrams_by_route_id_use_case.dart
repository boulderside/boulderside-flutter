import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class FetchInstagramsByRouteIdUseCase {
  const FetchInstagramsByRouteIdUseCase(this._repository);

  final InstagramRepository _repository;

  Future<Result<RouteInstagramPage>> call({
    required int routeId,
    int? cursor,
    int size = 10,
  }) {
    return _repository.fetchInstagramsByRouteId(
      routeId: routeId,
      cursor: cursor,
      size: size,
    );
  }
}
