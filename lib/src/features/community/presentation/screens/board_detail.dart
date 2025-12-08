import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/application/board_post_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BoardDetailPage extends ConsumerStatefulWidget {
  final BoardPost? post;
  const BoardDetailPage({super.key, this.post});

  @override
  ConsumerState<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends ConsumerState<BoardDetailPage> {
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.post?.id;
      if (id != null) {
        ref.read(boardPostStoreProvider.notifier).loadDetail(id);
      }
    });
  }

  String _formatExactDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editPost(BoardPostResponse post) {
    context
        .push<BoardPostResponse>(AppRoutes.communityBoardCreate, extra: post)
        .then((updatedPost) {
          if (!mounted || widget.post == null) return;
          if (updatedPost != null) {
            ref
                .read(boardPostStoreProvider.notifier)
                .loadDetail(widget.post!.id, forceRefresh: true);
          }
        });
  }

  Future<void> _deletePost(int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '게시글 삭제',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: const Text(
          '이 게시글을 삭제하시겠습니까?',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(boardPostStoreProvider.notifier).deletePost(postId);
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
        context.pop(true); // Return true to indicate deletion
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 삭제에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reportPost() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('신고 기능은 향후 구현될 예정입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post?.id;
    final detail = postId != null
        ? ref.watch(boardPostDetailProvider(postId))
        : const BoardPostDetailViewData(
            detail: null,
            fallback: null,
            isLoading: false,
            errorMessage: '게시글 정보를 찾을 수 없습니다.',
          );
    final fallback =
        widget.post ??
        detail.fallback ??
        BoardPost(
          id: 0,
          title: '게시판 상세',
          authorNickname: 'guest',
          commentCount: 0,
          viewCount: 0,
          createdAt: DateTime.now(),
          content: '게시판 글 내용이 없습니다.',
        );
    final postDetail = detail.detail;
    final isLoading = (detail.isLoading && postDetail == null);

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop(true); // Return true to trigger refresh
            },
          ),
          title: const Text('게시판 글', style: TextStyle(color: Colors.white)),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF3278)),
        ),
      );
    }

    final bool isAuthor = postDetail?.isMine ?? false;
    final viewCount = postDetail?.viewCount ?? fallback.viewCount;
    final commentCount = postDetail?.commentCount ?? fallback.commentCount;
    final boardTitle = postDetail?.title ?? fallback.title;
    final authorName = postDetail?.userInfo.nickname ?? fallback.authorNickname;
    final content = postDetail?.content ?? fallback.content ?? '';
    final createdAt = postDetail?.createdAt ?? fallback.createdAt;
    final domainId = postDetail?.boardPostId ?? fallback.id;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && mounted) {
          context.pop(result ?? false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.pop(true); // Return true to trigger refresh
            },
          ),
          title: const Text('게시판 글', style: TextStyle(color: Colors.white)),
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Colors.white,
              ),
              onOpened: () => setState(() => _isMenuOpen = true),
              onCanceled: () {
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) return;
                  setState(() => _isMenuOpen = false);
                });
              },
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    if (postDetail != null) {
                      _editPost(postDetail);
                    }
                    break;
                  case 'delete':
                    if (domainId != 0) {
                      _deletePost(domainId);
                    }
                    break;
                  case 'report':
                    _reportPost();
                    break;
                }
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) return;
                  setState(() => _isMenuOpen = false);
                });
              },
              itemBuilder: (context) {
                if (isAuthor) {
                  return const [
                    PopupMenuItem(value: 'edit', child: Text('수정')),
                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                  ];
                } else {
                  return const [
                    PopupMenuItem(value: 'report', child: Text('신고')),
                  ];
                }
              },
            ),
          ],
        ),
        body: IgnorePointer(
          ignoring: _isMenuOpen,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // Post content section
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Card(
                    color: const Color(0xFF262A34),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            boardTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.person_fill,
                                size: 18,
                                color: Color(0xFF7C7C7C),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                authorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                CupertinoIcons.eye,
                                size: 18,
                                color: Color(0xFF7C7C7C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$viewCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                CupertinoIcons.chat_bubble_text,
                                size: 18,
                                color: Color(0xFF7C7C7C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$commentCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatExactDateTime(createdAt),
                                style: const TextStyle(
                                  color: Color(0xFFB0B3B8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            content.isNotEmpty ? content : '작성된 본문이 없습니다.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Comments section
                Expanded(
                  child: CommentList(
                    domainType: 'board-posts',
                    domainId: domainId,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
