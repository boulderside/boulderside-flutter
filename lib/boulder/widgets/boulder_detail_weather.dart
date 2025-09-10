import 'package:flutter/material.dart';

class BoulderDetailWeather extends StatefulWidget {
  const BoulderDetailWeather({super.key});

  @override
  State<BoulderDetailWeather> createState() => _BoulderDetailWeatherState();
}

class _BoulderDetailWeatherState extends State<BoulderDetailWeather> {
  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional(-1, 0),
      child: _WeatherList(),
    );
  }
}

class _WeatherList extends StatelessWidget {
  const _WeatherList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: const [
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/580/600',
          dateText: '9월 3일',
        ),
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/581/600',
          dateText: '9월 4일',
        ),
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/581/600',
          dateText: '9월 4일',
        ),
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/581/600',
          dateText: '9월 4일',
        ),
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/581/600',
          dateText: '9월 4일',
        ),
        _WeatherCard(
          imageUrl: 'https://picsum.photos/seed/581/600',
          dateText: '9월 4일',
        ),
        // TODO: API 응답 데이터로 표시해주어야 함
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.imageUrl, required this.dateText});

  final String imageUrl;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '26°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
