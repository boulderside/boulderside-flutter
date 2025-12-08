class DailyWeatherInfo {
  const DailyWeatherInfo({
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
    this.rainVolume,
    this.rainProbability,
    required this.weatherIcon,
    required this.weatherId,
    required this.weatherMain,
    required this.weatherDescription,
  });

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
}
