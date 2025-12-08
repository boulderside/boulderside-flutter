import 'package:boulderside_flutter/src/features/boulder/domain/models/daily_weather_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BoulderDetailWeather extends StatelessWidget {
  const BoulderDetailWeather({super.key, required this.weather, this.onTap});

  final List<DailyWeatherInfo> weather;
  final void Function(DailyWeatherInfo info)? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: weather.length,
        itemBuilder: (context, index) {
          final info = weather[index];
          return _WeatherCard(
            info: info,
            onTap: onTap,
          );
        },
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.info, this.onTap});

  final DailyWeatherInfo info;
  final void Function(DailyWeatherInfo info)? onTap;

  @override
  Widget build(BuildContext context) {
    final dateText = '${info.date.month}월 ${info.date.day}일';
    final tempText = '${info.tempMin.round()}° / ${info.tempMax.round()}°';
    final iconUrl = _resolveIconUrl(info.weatherIcon);

    return GestureDetector(
      onTap: () => onTap?.call(info),
      child: Container(
        width: 90,
        margin: const EdgeInsetsDirectional.only(end: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0x332F3440),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (iconUrl != null)
              Image.network(
                iconUrl,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    CupertinoIcons.cloud_sun,
                    color: Colors.white70,
                    size: 32,
                  );
                },
              )
            else
              const Icon(
                CupertinoIcons.cloud_sun,
                color: Colors.white70,
                size: 32,
              ),
            const SizedBox(height: 8),
            Text(
              tempText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveIconUrl(String icon) {
    if (icon.isEmpty) return null;
    if (icon.startsWith('http')) return icon;
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
