import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';

abstract class RecBoulderRepository {
  Future<Result<RecBoulderPage>> fetchBoulders({
    required String sortType,
    int? cursor,
    String? subCursor,
    int size,
  });
}
