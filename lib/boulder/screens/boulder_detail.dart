import 'package:boulderside_flutter/boulder/widgets/approach_detail.dart';
import 'package:boulderside_flutter/boulder/widgets/boulder_detail_desc.dart';
import 'package:boulderside_flutter/boulder/widgets/boulder_detail_images.dart';
import 'package:boulderside_flutter/boulder/widgets/boulder_detail_weather.dart';
import 'package:boulderside_flutter/boulder/widgets/expandable_section.dart';
import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/screens/route_detail_page.dart';
import 'package:boulderside_flutter/home/widgets/route_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 어프로치 개수만큼 false로 초기화
    _approachExpanded = List.generate(approachCnt, (_) => false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openRouteDetail(RouteModel route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RouteDetailPage(route: route),
      ),
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        automaticallyImplyLeading: false, // 기본 ← 버튼 안 쓰고
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ), // < 아이콘 쓰기
          onPressed: () => Navigator.pop(context),
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
                    BoulderDetailImages(
                      imageUrls: const [
                        'https://picsum.photos/seed/322/600',
                        'https://picsum.photos/seed/222/600',
                        'https://picsum.photos/seed/122/600',
                      ],
                      height: 200,
                      storageKey: 'boulder_detail_images', // 같은 화면에서 유일하게만 유지
                    ),

                    // 설명 영역
                    BoulderDetailDesc(boulder: widget.boulder),

                    // 날씨 영역
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
                                label: "주차장",
                              ),
                              ApproachItem(
                                title: '등산로 입구 계단',
                                imageUrls: [
                                  'https://picsum.photos/seed/510/600',
                                  'https://picsum.photos/seed/511/600',
                                ],
                                label: "주차장",
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
    );
  }
}
