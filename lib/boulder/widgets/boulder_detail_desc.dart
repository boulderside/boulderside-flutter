import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BoulderDetailDesc extends StatefulWidget {
  const BoulderDetailDesc({super.key, required this.boulder});

  final BoulderModel boulder;

  @override
  State<BoulderDetailDesc> createState() => _BoulderDetailDescState();
}

class _BoulderDetailDescState extends State<BoulderDetailDesc> {
  late bool isLiked;
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.boulder.liked;
    currentLikes = widget.boulder.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final String locationText =
        (widget.boulder.city == null || widget.boulder.city!.isEmpty)
        ? widget.boulder.province
        : '${widget.boulder.province} ${widget.boulder.city}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 5, 10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목/위치 + 좋아요
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽: 제목 + 위치
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.boulder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF9498A1),
                          size: 20,
                        ),
                        Text(
                          locationText,
                          style: const TextStyle(
                            color: Color(0xFF7C7C7C),
                            fontSize: 14,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 오른쪽: 좋아요 토글 + 수
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
                      color: isLiked ? Colors.red : const Color(0xFF9498A1),
                      size: 24,
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
            ],
          ),

          // 설명
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            child: Text(
              (widget.boulder.description?.trim().isNotEmpty ?? false)
                  ? widget.boulder.description!.trim()
                  : 'Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante... (바위 설명)',
              style: const TextStyle(
                fontFamily: 'SFPRO',
                color: Color(0xFF7C7C7C),
                fontSize: 14,
                letterSpacing: 0.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLikes(int n) {
    if (n >= 1000000)
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 1000)
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    return '$n';
  }
}
