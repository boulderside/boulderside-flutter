import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/dtos/boulder_dto.dart';
import 'package:dio/dio.dart';

class BoulderDetailService {
  BoulderDetailService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<BoulderModel> fetchDetail(int boulderId) async {
    final response = await _dio.get('/boulders/$boulderId');
    if (response.statusCode == 200) {
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return BoulderDto.fromJson(data).toDomain();
      }
    }
    throw Exception('바위 정보를 불러오지 못했습니다.');
  }
}
