import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';

abstract class MapRepository {
  Future<Result<List<BoulderModel>>> fetchAllBoulders();
}
