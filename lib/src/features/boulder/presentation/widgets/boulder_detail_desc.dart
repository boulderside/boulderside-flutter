import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BoulderDetailDesc extends StatefulWidget {
  const BoulderDetailDesc({
    super.key,
    required this.boulder,
    this.onLikeChanged,
  });

  final BoulderModel boulder;
  final VoidCallback? onLikeChanged;

  @override
  State<BoulderDetailDesc> createState() => _BoulderDetailDescState();
}

class _BoulderDetailDescState extends State<BoulderDetailDesc> {
  late bool isLiked;
  late int currentLikes;
  bool _isProcessing = false;
  late final LikeService _likeService;

  @override
  void initState() {
    super.initState();
    _likeService = context.read<LikeService>();
    isLiked = widget.boulder.liked;
    currentLikes = widget.boulder.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final locationText = widget.boulder.city.isEmpty
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
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
                    onTap: _isProcessing ? null : _handleToggle,
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
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
            child: Text(
              widget.boulder.description.trim().isNotEmpty
                  ? widget.boulder.description.trim()
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

  Future<void> _handleToggle() async {
    if (_isProcessing) return;
    final previousLiked = isLiked;
    final previousLikes = currentLikes;
    setState(() {
      _isProcessing = true;
      isLiked = !isLiked;
      currentLikes += isLiked ? 1 : -1;
    });
    try {
      final result =
          await _likeService.toggleBoulderLike(widget.boulder.id);
      if (!mounted) return;
      setState(() {
        if (result.liked != null) {
          final desired = result.liked!;
          if (isLiked != desired) {
            currentLikes += desired ? 1 : -1;
          }
          isLiked = desired;
        }
        if (result.likeCount != null) {
          currentLikes = result.likeCount!;
        }
        widget.onLikeChanged?.call();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLiked = previousLiked;
        currentLikes = previousLikes;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('좋아요를 변경하지 못했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
