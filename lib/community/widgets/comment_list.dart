import 'package:flutter/material.dart';
import '../models/comment.dart';

class CommentList extends StatelessWidget {
  final List<CommentModel> comments;
  const CommentList({super.key, required this.comments});

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inHours < 1) return '${duration.inMinutes}분 전';
    if (duration.inDays < 1) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '첫 번째 댓글을 남겨보세요!',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Color(0xFFB0B3B8),
            fontSize: 14,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xFF333741), height: 20),
      itemBuilder: (context, index) {
        final c = comments[index];
        const double avatarRadius = 16;
        const double horizontalGap = 12;
        final double contentIndent = avatarRadius * 2 + horizontalGap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: const Color(0xFF333741),
                  child: Text(
                    c.authorNickname.isNotEmpty ? c.authorNickname[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: horizontalGap),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.authorNickname,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(c.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color(0xFF9FA3A9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _CommentActions(authorNickname: c.authorNickname),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(left: contentIndent),
              child: Text(
                c.content,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommentActions extends StatelessWidget {
  final String authorNickname;
  const _CommentActions({required this.authorNickname});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real current user nickname from auth/session
    const String currentNickname = 'me';
    final bool isAuthor = authorNickname == currentNickname;

    if (!isAuthor) {
      return PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 18,
        icon: const Icon(Icons.more_vert, color: Color(0xFFB0B3B8)),
        onSelected: (value) {
          if (value == 'report') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report Comment tapped')),
            );
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'report', child: Text('Report Comment')),
        ],
      );
    }

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: const Icon(Icons.more_vert, color: Color(0xFFB0B3B8)),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit Comment tapped')),
            );
            break;
          case 'delete':
            final messenger = ScaffoldMessenger.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Comment'),
                content: const Text('Are you sure you want to delete this comment?'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                ],
              ),
            );
            if (confirmed == true) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Comment deleted')),
              );
            }
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit Comment')),
        PopupMenuItem(value: 'delete', child: Text('Delete Comment')),
      ],
    );
  }
}
