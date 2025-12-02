import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';

abstract class BoulderRepository {
  Future<Result<PaginatedBoulders>> fetchBoulders({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size,
  });
}
