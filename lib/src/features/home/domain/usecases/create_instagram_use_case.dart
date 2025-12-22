import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class CreateInstagramUseCase {
  CreateInstagramUseCase(this._repository);

  final InstagramRepository _repository;

  Future<void> execute({required String url, required List<int> routeIds}) {
    return _repository.createInstagram(url: url, routeIds: routeIds);
  }
}
