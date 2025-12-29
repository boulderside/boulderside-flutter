import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_detail.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class FetchInstagramDetailUseCase {
  const FetchInstagramDetailUseCase(this._repository);

  final InstagramRepository _repository;

  Future<Result<InstagramDetail>> call(int instagramId) {
    return _repository.fetchInstagramDetail(instagramId);
  }
}
