import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class UpdateInstagramUseCase {
  const UpdateInstagramUseCase(this._repository);

  final InstagramRepository _repository;

  Future<Result<void>> call({
    required int instagramId,
    required String url,
    required List<int> routeIds,
  }) {
    return _repository.updateInstagram(
      instagramId: instagramId,
      url: url,
      routeIds: routeIds,
    );
  }
}
