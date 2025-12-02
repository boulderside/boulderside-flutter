import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this._boulderService);

  final BoulderService _boulderService;

  @override
  Future<Result<List<BoulderModel>>> fetchAllBoulders() async {
    try {
      final boulders = await _boulderService.fetchAllBoulders();
      return Result.success(boulders);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
