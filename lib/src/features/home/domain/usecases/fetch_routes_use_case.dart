import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_routes.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/route_repository.dart';

class FetchRoutesUseCase {
  const FetchRoutesUseCase(this._repository);

  final RouteRepository _repository;

  Future<Result<PaginatedRoutes>> call({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size = 5,
  }) {
    return _repository.fetchRoutes(
      sortType: sortType,
      cursor: cursor,
      subCursor: subCursor,
      size: size,
    );
  }
}
