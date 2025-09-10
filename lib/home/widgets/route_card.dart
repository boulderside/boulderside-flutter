import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteCard extends StatefulWidget {
  final RouteModel route;
  final bool showChevron; // > 아이콘 표시 여부

  const RouteCard({super.key, required this.route, this.showChevron = false});

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  late bool isLiked;
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.route.isLiked;
    currentLikes = widget.route.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        widget.showChevron ? 10 : 20,
        0,
        widget.showChevron ? 10 : 20,
        widget.showChevron ? 0 : 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // > 아이콘 수직 중앙 정렬
        children: [
          // 왼쪽: 카드(이름, 레벨, 좋아요, 등반자 수)
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: const Color(0xFF262A34),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 상단: 이름 + 바위명 + 등급 이미지
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      10,
                      widget.showChevron ? 0 : 15,
                      10,
                      0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 루트 이름 + 바위명
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                widget.showChevron ? 0 : 10,
                                0,
                                0,
                                0,
                              ),
                              child: Text(
                                widget.route.name,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 하단: 좋아요 + 등반자 수
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      10,
                      5,
                      10,
                      15,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 레벨
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            widget.showChevron ? 0 : 10,
                            0,
                            0,
                            0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.route.routeLevel,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 좋아요 토글
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLiked = !isLiked;
                                  currentLikes += isLiked ? 1 : -1;
                                  // TODO: 좋아요 API 호출
                                });
                              },
                              child: Icon(
                                isLiked
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                color: isLiked
                                    ? Colors.red
                                    : const Color(0xFF9498A1),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 4), // 아이콘과 텍스트 사이 거리 조절
                            Text(
                              '$currentLikes',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        //const SizedBox(width: 15),
                        const Spacer(),

                        // 등반자 수
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            0,
                            0,
                            10,
                            0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '(${widget.route.climbers}명 등반)',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Color(0xFF9498A1),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 오른쪽: > 아이콘 (옵션)
          if (widget.showChevron)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
              child: const Icon(
                CupertinoIcons.chevron_forward,
                color: Color(0xFF9498A1),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
