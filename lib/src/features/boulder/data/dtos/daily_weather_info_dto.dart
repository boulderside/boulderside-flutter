import 'package:boulderside_flutter/src/features/boulder/domain/models/daily_weather_info.dart';

class DailyWeatherInfoDto {
  DailyWeatherInfoDto({
    required this.date,
    required this.summary,
    required this.tempMorn,
    required this.tempDay,
    required this.tempEve,
    required this.tempNight,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.rainVolume,
    required this.rainProbability,
    required this.weatherIcon,
    required this.weatherId,
    required this.weatherMain,
    required this.weatherDescription,
  });

  factory DailyWeatherInfoDto.fromJson(Map<String, dynamic> json) {
    return DailyWeatherInfoDto(
      date: DateTime.parse(json['date'] as String),
      summary: json['summary'] as String? ?? '',
      tempMorn: (json['tempMorn'] as num).toDouble(),
      tempDay: (json['tempDay'] as num).toDouble(),
      tempEve: (json['tempEve'] as num).toDouble(),
      tempNight: (json['tempNight'] as num).toDouble(),
      tempMin: (json['tempMin'] as num).toDouble(),
      tempMax: (json['tempMax'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      rainVolume: (json['rainVolume'] as num?)?.toDouble(),
      rainProbability: (json['rainProbability'] as num?)?.toDouble(),
      weatherIcon: json['weatherIcon'] as String? ?? '',
      weatherId: (json['weatherId'] as num).toInt(),
      weatherMain: json['weatherMain'] as String? ?? '',
      weatherDescription: json['weatherDescription'] as String? ?? '',
    );
  }

  final DateTime date;
  final String summary;
  final double tempMorn;
  final double tempDay;
  final double tempEve;
  final double tempNight;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final double? rainVolume;
  final double? rainProbability;
  final String weatherIcon;
  final int weatherId;
  final String weatherMain;
  final String weatherDescription;

  DailyWeatherInfo toDomain() {
    return DailyWeatherInfo(
      date: date,
      summary: summary,
      tempMorn: tempMorn,
      tempDay: tempDay,
      tempEve: tempEve,
      tempNight: tempNight,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed,
      rainVolume: rainVolume,
      rainProbability: rainProbability,
      weatherIcon: weatherIcon,
      weatherId: weatherId,
      weatherMain: weatherMain,
      weatherDescription: weatherDescription,
    );
  }
}
