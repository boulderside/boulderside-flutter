import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_routes.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/route_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._service);

  final RouteService _service;

  @override
  Future<Result<PaginatedRoutes>> fetchRoutes({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size = 5,
  }) async {
    final result = await _service.fetchRoutes(
      routeSortType: sortType,
      cursor: cursor,
      subCursor: subCursor,
      size: size,
    );

    return result.when(
      success: (page) => Result.success(
        PaginatedRoutes(
          items: page.content,
          nextCursor: page.nextCursor,
          nextSubCursor: page.nextSubCursor,
          hasNext: page.hasNext,
        ),
      ),
      failure: Result.failure,
    );
  }
}
