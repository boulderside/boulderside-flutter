import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class DeleteInstagramUseCase {
  const DeleteInstagramUseCase(this._repository);

  final InstagramRepository _repository;

  Future<Result<void>> call(int instagramId) {
    return _repository.deleteInstagram(instagramId);
  }
}
