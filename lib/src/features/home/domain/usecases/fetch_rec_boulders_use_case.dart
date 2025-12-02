import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/rec_boulder_repository.dart';

class FetchRecBouldersUseCase {
  const FetchRecBouldersUseCase(this._repository);

  final RecBoulderRepository _repository;

  Future<Result<RecBoulderPage>> call({
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
