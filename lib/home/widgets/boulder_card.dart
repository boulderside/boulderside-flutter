import 'package:flutter/material.dart';
import '../models/boulder_model.dart';

class BoulderCard extends StatefulWidget {
  final BoulderModel boulder;

  const BoulderCard({super.key, required this.boulder});

  @override
  State<BoulderCard> createState() => _BoulderCardState();
}

class _BoulderCardState extends State<BoulderCard> {
  late bool isLiked;
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.boulder.isLiked;
    currentLikes = widget.boulder.likes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              widget.boulder.imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          // 본문
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 바위 이름
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.boulder.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                // 좋아요 + 위치
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 좋아요 버튼 + 수
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked
                                ? Colors.red
                                : const Color(0xFF9498A1),
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                              currentLikes += isLiked ? 1 : -1;

                              /// TODO : 좋아요 처리 API 호출
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

                    const SizedBox(width: 25),

                    // 위치
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF7C7C7C),
                          size: 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.boulder.location,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
