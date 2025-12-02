import 'package:boulderside_flutter/src/app/di/dependencies.dart';
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
import 'package:provider/provider.dart';

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
  int approachCnt = 2; // 임시 데이터. 어프로치 방법의 개수를 말함
  late List<bool> _approachExpanded; // 어프로치별 확장 여부 리스트
  bool _routeExpanded = false;
  bool _likeChanged = false;

  late final BoulderDetailService _detailService;
  late BoulderModel _boulder;
  bool _isLoading = false;
  String? _errorMessage;

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
    _boulder = widget.boulder;
    _approachExpanded = List.generate(approachCnt, (_) => false);
    if (_boulder.description.isEmpty ||
        _boulder.province.isEmpty ||
        _boulder.city.isEmpty) {
      _fetchDetail();
    }
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
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF3278),
                            ),
                          ),
                        )
                      else
                        BoulderDetailImages(
                          imageUrls: const [
                            'https://picsum.photos/seed/322/600',
                            'https://picsum.photos/seed/222/600',
                            'https://picsum.photos/seed/122/600',
                          ],
                          height: 200,
                          storageKey: 'boulder_detail_images',
                        ),
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
                          child: const SizedBox(
                            height: 120,
                            child: BoulderDetailWeather(),
                          ),
                        ),
                      // 어프로치 영역
                      if (_errorMessage == null)
                        Column(
                          children: List.generate(approachCnt, (index) {
                            return ExpandableSection(
                              title: '어프로치 정보 ${index + 1}',
                              expanded: _approachExpanded[index],
                              onToggle: () {
                                setState(() {
                                  _approachExpanded[index] =
                                      !_approachExpanded[index];
                                });
                              },
                              child: ApproachDetail(
                                items: const [
                                  ApproachItem(
                                    title: '군포 시민 체육 광장',
                                    imageUrls: [
                                      'https://picsum.photos/seed/508/600',
                                      'https://picsum.photos/seed/509/600',
                                    ],
                                    label: '주차장',
                                  ),
                                  ApproachItem(
                                    title: '등산로 입구 계단',
                                    imageUrls: [
                                      'https://picsum.photos/seed/510/600',
                                      'https://picsum.photos/seed/511/600',
                                    ],
                                    label: '주차장',
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
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
}
