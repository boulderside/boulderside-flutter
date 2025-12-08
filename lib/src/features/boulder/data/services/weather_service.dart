import 'package:boulderside_flutter/src/features/boulder/data/dtos/daily_weather_info_dto.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/daily_weather_info.dart';
import 'package:dio/dio.dart';

class WeatherService {
  WeatherService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<List<DailyWeatherInfo>> fetchWeather({required int boulderId}) async {
    final response = await _dio.get(
      '/weather',
      queryParameters: {'boulderId': boulderId},
    );

    if (response.statusCode == 200) {
      final dynamic data = response.data['data'] ?? response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => DailyWeatherInfoDto.fromJson(json).toDomain())
            .toList();
      }
    }
    throw Exception('날씨 정보를 불러오지 못했습니다.');
  }
}
