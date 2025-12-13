import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BoardPostCard extends StatelessWidget {
  final BoardPost post;
  final VoidCallback? onRefresh;
  const BoardPostCard({super.key, required this.post, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
      child: InkWell(
        onTap: () async {
          await context.push<bool>(AppRoutes.communityBoardDetail, extra: post);
          if (!context.mounted) return;
          onRefresh?.call();
        },
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: const Color(0xFF262A34),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      post.authorNickname,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFFB0B3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFF7C7C7C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(post.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFF7C7C7C),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      CupertinoIcons.chat_bubble_text,
                      size: 16,
                      color: Color(0xFF9498A1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      CupertinoIcons.eye,
                      size: 16,
                      color: Color(0xFF9498A1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.viewCount}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);

    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inMinutes < 60) return '${duration.inMinutes}분 전';
    if (duration.inHours < 24) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    if (duration.inDays < 30) return '${(duration.inDays / 7).floor()}주 전';
    if (duration.inDays < 365) return '${(duration.inDays / 30).floor()}개월 전';

    return '${(duration.inDays / 365).floor()}년 전';
  }
}
