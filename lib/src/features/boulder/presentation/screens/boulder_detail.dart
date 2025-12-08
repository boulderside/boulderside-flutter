import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/approach_service.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/weather_service.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/approach_model.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/daily_weather_info.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/widgets/approach_detail.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/widgets/boulder_detail_desc.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/widgets/boulder_detail_images.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/widgets/boulder_detail_weather.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/widgets/expandable_section.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_detail_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoulderDetail extends StatefulWidget {
  const BoulderDetail({super.key, required this.boulder});

  final BoulderModel boulder; // 리스트에서 넘겨주는 데이터

  static String routeName = 'BoulderDetail';
  static String routePath = '/boulderDetail';

  @override
  State<BoulderDetail> createState() => _BoulderDetailState();
}

class _BoulderDetailState extends State<BoulderDetail> {
  bool _weatherExpanded = false;
  List<bool> _approachExpanded = <bool>[]; // 어프로치별 확장 여부 리스트
  bool _routeExpanded = false;
  bool _likeChanged = false;

  late final BoulderDetailService _detailService;
  late final ApproachService _approachService;
  late final WeatherService _weatherService;
  late BoulderModel _boulder;
  bool _isLoading = false;
  String? _errorMessage;
  List<DailyWeatherInfo> _weather = <DailyWeatherInfo>[];
  bool _isWeatherLoading = false;
  String? _weatherError;
  List<ApproachModel> _approaches = <ApproachModel>[];
  bool _isApproachLoading = false;
  String? _approachError;

  // 루트 관련 더미데이터
  final List<RouteModel> routes = [
    RouteModel(
      id: 1,
      boulderId: 101,
      province: '경기도',
      city: '군포시',
      name: "레드 다이아몬드",
      pioneerName: "홍길동",
      latitude: 37.0,
      longitude: 126.9,
      sectorName: 'A섹터',
      areaCode: 'KR-41-620',
      routeLevel: "V3",
      likeCount: 12,
      liked: false,
      viewCount: 200,
      climberCount: 5,
      commentCount: 2,
      imageInfoList: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    RouteModel(
      id: 2,
      boulderId: 101,
      province: '경기도',
      city: '군포시',
      name: "블루 크랙",
      pioneerName: "김철수",
      latitude: 37.1,
      longitude: 127.0,
      sectorName: 'B섹터',
      areaCode: 'KR-41-620',
      routeLevel: "V5",
      likeCount: 30,
      liked: true,
      viewCount: 450,
      climberCount: 12,
      commentCount: 7,
      imageInfoList: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _detailService = di<BoulderDetailService>();
    _approachService = di<ApproachService>();
    _weatherService = di<WeatherService>();
    _boulder = widget.boulder;
    if (_boulder.description.isEmpty ||
        _boulder.province.isEmpty ||
        _boulder.city.isEmpty) {
      _fetchDetail();
    }
    _fetchApproaches();
    _fetchWeather();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openRouteDetail(RouteModel route) {
    context.push(AppRoutes.routeDetail, extra: route);
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _detailService.fetchDetail(widget.boulder.id);
      if (!mounted) return;
      setState(() {
        _boulder = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '바위 정보를 불러오지 못했습니다.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('바위 정보를 불러오지 못했습니다: $e')));
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isWeatherLoading = true;
      _weatherError = null;
    });
    try {
      final weather = await _weatherService.fetchWeather(
        boulderId: widget.boulder.id,
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isWeatherLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isWeatherLoading = false;
        _weatherError = '날씨 정보를 불러오지 못했습니다.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('날씨 정보를 불러오지 못했습니다: $e')),
      );
    }
  }

  Future<void> _fetchApproaches() async {
    setState(() {
      _isApproachLoading = true;
      _approachError = null;
    });
    try {
      final approaches = await _approachService.fetchApproaches(
        widget.boulder.id,
      );
      if (!mounted) return;
      approaches.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      setState(() {
        _approaches = approaches;
        _approachExpanded = List<bool>.filled(approaches.length, false);
        _isApproachLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isApproachLoading = false;
        _approachError = '어프로치 정보를 불러오지 못했습니다.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('어프로치 정보를 불러오지 못했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && mounted) {
          context.pop(result ?? _likeChanged);
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => context.pop(_likeChanged),
          ),
          title: const Text(
            '바위 상세',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'pretendard',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 2, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    children: [
                      // 이미지 영역
                      _buildImageSection(),
                      // 설명 영역
                      BoulderDetailDesc(
                        boulder: _boulder,
                        onLikeChanged: () => _likeChanged = true,
                      ),
                      // 날씨 영역
                      if (_errorMessage == null)
                        ExpandableSection(
                          title: '날씨 정보',
                          expanded: _weatherExpanded,
                          onToggle: () {
                            setState(() {
                              _weatherExpanded = !_weatherExpanded;
                            });
                          },
                          child: _buildWeatherContent(),
                        ),
                      // 어프로치 영역
                      if (_errorMessage == null) _buildApproachSection(),
                      // 루트 영역
                      ExpandableSection(
                        title: '루트',
                        expanded: _routeExpanded,
                        onToggle: () {
                          setState(() {
                            _routeExpanded = !_routeExpanded;
                          });
                        },
                        child: Column(
                          children: routes
                              .map(
                                (route) => RouteCard(
                                  route: route,
                                  showChevron: true,
                                  onTap: () => _openRouteDetail(route),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

  Widget _buildWeatherContent() {
    if (_isWeatherLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF3278),
          ),
        ),
      );
    }

    if (_weatherError != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            _weatherError!,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (_weather.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            '날씨 정보가 없습니다.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: BoulderDetailWeather(
        weather: _weather,
        onTap: _showWeatherDetail,
      ),
    );
  }

  Widget _buildApproachSection() {
    if (_isApproachLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF3278),
          ),
        ),
      );
    }

    if (_approachError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            _approachError!,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    if (_approaches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '어프로치 정보가 없습니다.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_approaches.length, (index) {
        final approach = _approaches[index];
        final title = '어프로치 ${index + 1}';
        final expanded =
            index < _approachExpanded.length && _approachExpanded[index];
        return ExpandableSection(
          title: title,
          expanded: expanded,
          onToggle: () {
            setState(() {
              if (index >= _approachExpanded.length) {
                _approachExpanded = List<bool>.filled(
                  _approaches.length,
                  false,
                );
              }
              _approachExpanded[index] = !_approachExpanded[index];
            });
          },
          child: _buildApproachDetail(approach),
        );
      }),
    );
  }

  Widget _buildApproachDetail(ApproachModel approach) {
    final items = approach.points
        .map(
          (point) => ApproachItem(
            title:
                point.name.isNotEmpty ? point.name : '지점 ${point.orderIndex}',
            imageUrls:
                point.images.map((image) => image.imageUrl).toList(),
            description: point.description,
            note: point.note,
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (approach.transportInfo.isNotEmpty)
            _ApproachInfoRow(label: '이동 수단', value: approach.transportInfo),
          if (approach.parkingInfo.isNotEmpty)
            _ApproachInfoRow(label: '주차 정보', value: approach.parkingInfo),
          if (approach.duration > 0)
            _ApproachInfoRow(
              label: '예상 소요시간',
              value: '${approach.duration}분',
            ),
          if (approach.tip.isNotEmpty)
            _ApproachInfoRow(label: 'TIP', value: approach.tip),
          ApproachDetail(items: items),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF3278),
          ),
        ),
      );
    }

    final imageUrls = _boulder.imageInfoList
        .map((info) => info.imageUrl.trim())
        .where((url) => url.isNotEmpty)
        .toList();

    if (imageUrls.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF2F3440),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const Icon(
          CupertinoIcons.photo,
          color: Color(0xFF7C7C7C),
          size: 48,
        ),
      );
    }

    return BoulderDetailImages(
      imageUrls: imageUrls,
      height: 200,
      storageKey: 'boulder_detail_images',
    );
  }

  void _showWeatherDetail(DailyWeatherInfo info) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final iconUrl = info.weatherIcon.isNotEmpty
            ? (info.weatherIcon.startsWith('http')
                ? info.weatherIcon
                : 'https://openweathermap.org/img/wn/${info.weatherIcon}@2x.png')
            : null;
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E2129),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${info.date.month}월 ${info.date.day}일',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (iconUrl != null)
                      Image.network(
                        iconUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      )
                    else
                      const Icon(
                        CupertinoIcons.cloud_sun,
                        color: Colors.white70,
                        size: 48,
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.summary.isNotEmpty
                                ? info.summary
                                : info.weatherMain,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info.weatherDescription,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _WeatherDetailRow(
                  label: '기온 (최저 / 최고)',
                  value:
                      '${info.tempMin.toStringAsFixed(1)}°C / ${info.tempMax.toStringAsFixed(1)}°C',
                ),
                _WeatherDetailRow(
                  label: '아침 / 낮 / 저녁 / 밤',
                  value:
                      '${info.tempMorn.toStringAsFixed(1)}°C / ${info.tempDay.toStringAsFixed(1)}°C / ${info.tempEve.toStringAsFixed(1)}°C / ${info.tempNight.toStringAsFixed(1)}°C',
                ),
                _WeatherDetailRow(
                  label: '습도',
                  value: '${info.humidity}%',
                ),
                _WeatherDetailRow(
                  label: '풍속',
                  value: '${info.windSpeed.toStringAsFixed(1)}m/s',
                ),
                if (info.rainProbability != null)
                  _WeatherDetailRow(
                    label: '강수 확률',
                    value: '${(info.rainProbability! * 100).round()}%',
                  ),
                if (info.rainVolume != null)
                  _WeatherDetailRow(
                    label: '강수량',
                    value: '${info.rainVolume!.toStringAsFixed(1)}mm',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeatherDetailRow extends StatelessWidget {
  const _WeatherDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApproachInfoRow extends StatelessWidget {
  const _ApproachInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
