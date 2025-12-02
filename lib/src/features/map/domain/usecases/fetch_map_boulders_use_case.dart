import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/map/domain/repositories/map_repository.dart';

class FetchMapBouldersUseCase {
  const FetchMapBouldersUseCase(this._repository);

  final MapRepository _repository;

  Future<Result<List<BoulderModel>>> call() {
    return _repository.fetchAllBoulders();
  }
}
