import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteCard extends StatefulWidget {
  final RouteModel route;

  const RouteCard({super.key, required this.route});

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
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFF262A34),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 상단: 이름 + 바위명 + 등급 이미지
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 0),
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
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10,
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          10,
                          5,
                          0,
                          0,
                        ),
                        child: Text(
                          widget.route.name,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Color(0xFF9498A1),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // 등급 이미지 (routeLevel)
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/level/${widget.route.routeLevel.toLowerCase()}.png',
                        width: 35,
                        height: 35,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 하단: 좋아요 + 등반자 수
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 좋아요 토글
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isLiked ? Colors.red : const Color(0xFF9498A1),
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                            currentLikes += isLiked ? 1 : -1;
                            // TODO: 좋아요 API 호출
                          });
                        },
                      ),
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

                  const SizedBox(width: 20),

                  // 등반자 수
                  Row(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
