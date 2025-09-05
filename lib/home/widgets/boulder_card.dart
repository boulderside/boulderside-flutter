import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/boulder_model.dart';

class BoulderCard extends StatefulWidget {
  final BoulderModel boulder;

  const BoulderCard({super.key, required this.boulder});

  @override
  State<BoulderCard> createState() => _BoulderCardState();
}

class _BoulderCardState extends State<BoulderCard> {
  late bool liked;
  late int currentLikes;

  @override
  void initState() {
    super.initState();
    liked = widget.boulder.liked;
    currentLikes = widget.boulder.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = widget.boulder.imageInfoList.isNotEmpty
        ? widget.boulder.imageInfoList.first.imageUrl
        : null;
    

    final bool hasValidImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    final String locationText =
        (widget.boulder.city == null || widget.boulder.city!.isEmpty)
        ? widget.boulder.province
        : '${widget.boulder.province} ${widget.boulder.city}';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFF262A34),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 200, // Fixed height - always reserved
                child: hasValidImage
                    ? Image.network(
                        // 이미지 url 이 있을 때
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          // Show loading indicator while image loads
                          return Container(
                            color: const Color(0xFF2F3440),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xFF7C7C7C),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),

            // 본문
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 20, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 바위 이름
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
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

                  // 좋아요 + 위치
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 좋아요 버튼 + 수
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              liked
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              color: liked
                                  ? Colors.red
                                  : const Color(0xFF9498A1),
                              size: 24,
                            ),
                            onPressed: () {
                              setState(() {
                                liked = !liked;
                                currentLikes += liked ? 1 : -1;

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

                      const SizedBox(width: 10),

                      // 위치
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Color(0xFF7C7C7C),
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationText,
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
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      // 이미지 url 이 없거나 로드 실패시 표시
      width: double.infinity,
      height: 200, // Same height as actual image
      color: const Color(0xFF2F3440),
      child: const Center(
        child: Icon(
          CupertinoIcons.photo,
          color: Color(0xFF7C7C7C),
          size: 40,
        ),
      ),
    );
  }
}
