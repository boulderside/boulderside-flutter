import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/services/instagram_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_detail.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/repositories/instagram_repository.dart';

class InstagramRepositoryImpl implements InstagramRepository {
  InstagramRepositoryImpl(this._service);

  final InstagramService _service;

  @override
  Future<void> createInstagram({
    required String url,
    required List<int> routeIds,
  }) {
    return _service.createInstagram(url: url, routeIds: routeIds);
  }

  @override
  Future<Result<InstagramPage>> fetchMyInstagrams({
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchMyInstagrams(
        cursor: cursor,
        size: size,
      );
      return Result.success(response.toDomain());
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<void>> deleteInstagram(int instagramId) async {
    try {
      await _service.deleteInstagram(instagramId);
      return Result.success(null);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<void>> updateInstagram({
    required int instagramId,
    required String url,
    required List<int> routeIds,
  }) async {
    try {
      await _service.updateInstagram(
        instagramId: instagramId,
        url: url,
        routeIds: routeIds,
      );
      return Result.success(null);
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<RouteInstagramPage>> fetchInstagramsByRouteId({
    required int routeId,
    int? cursor,
    int size = 10,
  }) async {
    try {
      final response = await _service.fetchInstagramsByRouteId(
        routeId: routeId,
        cursor: cursor,
        size: size,
      );
      return Result.success(response.toDomain());
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }

  @override
  Future<Result<InstagramDetail>> fetchInstagramDetail(int instagramId) async {
    try {
      final response = await _service.fetchInstagramDetail(instagramId);
      return Result.success(response.toDomain());
    } catch (error) {
      return Result.failure(AppFailure.fromException(error));
    }
  }
}
