import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_routes.dart';

abstract class RouteRepository {
  Future<Result<PaginatedRoutes>> fetchRoutes({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size,
  });
}
