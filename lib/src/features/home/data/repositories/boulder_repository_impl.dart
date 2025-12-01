import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/boulder_repository.dart';

class BoulderRepositoryImpl implements BoulderRepository {
  BoulderRepositoryImpl(this._service);

  final BoulderService _service;

  @override
  Future<Result<PaginatedBoulders>> fetchBoulders({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size = 5,
  }) async {
    final result = await _service.fetchBoulders(
      boulderSortType: sortType,
      cursor: cursor,
      subCursor: subCursor,
      size: size,
    );

    return result.when(
      success: (page) => Result.success(
        PaginatedBoulders(
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
