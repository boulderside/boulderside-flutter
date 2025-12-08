import 'package:boulderside_flutter/src/features/boulder/data/dtos/approach_dto.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/approach_model.dart';
import 'package:dio/dio.dart';

class ApproachService {
  ApproachService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<List<ApproachModel>> fetchApproaches(int boulderId) async {
    final response = await _dio.get('/boulders/$boulderId/approaches');

    if (response.statusCode == 200) {
      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ApproachDto.fromJson(json).toDomain())
            .toList();
      }
    }
    throw Exception('어프로치 정보를 불러오지 못했습니다.');
  }
}
