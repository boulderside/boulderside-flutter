import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/boulder_repository.dart';

class FetchBouldersUseCase {
  const FetchBouldersUseCase(this._repository);

  final BoulderRepository _repository;

  Future<Result<PaginatedBoulders>> call({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size = 5,
  }) {
    return _repository.fetchBoulders(
      sortType: sortType,
      cursor: cursor,
      subCursor: subCursor,
      size: size,
    );
  }
}
