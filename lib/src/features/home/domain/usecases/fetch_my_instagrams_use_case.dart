import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class FetchMyInstagramsUseCase {
  const FetchMyInstagramsUseCase(this._repository);

  final InstagramRepository _repository;

  Future<Result<InstagramPage>> call({int? cursor, int size = 10}) {
    return _repository.fetchMyInstagrams(cursor: cursor, size: size);
  }
}
