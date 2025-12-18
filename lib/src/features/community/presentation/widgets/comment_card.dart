import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/shared/widgets/avatar_placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
    this.onReport,
  });

  final CommentResponseModel comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMine = widget.comment.isMine;
    final Color bubbleColor =
        isMine ? const Color(0xFF1F2330) : const Color(0xFF181A20);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarPlaceholder(
                size: 32,
                imageUrl: widget.comment.userInfo.profileImageUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comment.userInfo.nickname,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(widget.comment.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.comment.isMine || widget.onReport != null)
                PopupMenuButton<String>(
                  icon: const Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white54,
                    size: 20,
                  ),
                  color: const Color(0xFF262A34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) {
                    if (widget.comment.isMine) {
                      return [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: const Row(
                            children: [
                              Icon(
                                CupertinoIcons.pencil,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '수정',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(
                                CupertinoIcons.delete,
                                color: Colors.red,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '삭제',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    }
                    if (widget.onReport == null) {
                      return const [];
                    }
                    return [
                      PopupMenuItem<String>(
                        value: 'report',
                        child: const Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '신고',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        widget.onEdit?.call();
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog();
                        break;
                      case 'report':
                        widget.onReport?.call();
                        break;
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.comment.content,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          if (widget.comment.createdAt != widget.comment.updatedAt)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '수정됨',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '댓글 삭제',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: const Text(
          '이 댓글을 삭제하시겠습니까?',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              widget.onDelete?.call();
            },
            child: const Text(
              '삭제',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
