import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';

class CommentCard extends StatefulWidget {
  final CommentResponseModel comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

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
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF181A20),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF262A34),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 유저 정보 및 액션 버튼
          Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF262A34),
                backgroundImage: widget.comment.userInfo.profileImageUrl != null
                    ? NetworkImage(widget.comment.userInfo.profileImageUrl!)
                    : null,
                child: widget.comment.userInfo.profileImageUrl == null
                    ? const Icon(
                        CupertinoIcons.person_fill,
                        size: 16,
                        color: Colors.white54,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // 닉네임 및 시간
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
              
              // 액션 버튼 (내 댓글일 때만 표시)
              if (widget.comment.isMine)
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
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.pencil, color: Colors.white, size: 16),
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
                          Icon(CupertinoIcons.delete, color: Colors.red, size: 16),
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
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        widget.onEdit?.call();
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog();
                        break;
                    }
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 댓글 내용
          Text(
            widget.comment.content,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          
          // 수정됨 표시
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
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
          ),
        ),
        content: const Text(
          '이 댓글을 삭제하시겠습니까?',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              widget.onDelete?.call();
            },
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
