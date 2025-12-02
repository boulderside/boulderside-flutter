import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/rec_boulder_repository.dart';

class RecBoulderRepositoryImpl implements RecBoulderRepository {
  RecBoulderRepositoryImpl(this._service);

  final RecBoulderService _service;

  @override
  Future<Result<RecBoulderPage>> fetchBoulders({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size = 5,
  }) async {
    try {
      final page = await _service.fetchBoulders(
        boulderSortType: sortType,
        cursor: cursor,
        subCursor: subCursor,
        size: size,
      );

      return Result.success(
        RecBoulderPage(
          items: page.items,
          nextCursor: page.nextCursor,
          nextSubCursor: page.nextSubCursor,
          hasNext: page.hasNext,
        ),
      );
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
