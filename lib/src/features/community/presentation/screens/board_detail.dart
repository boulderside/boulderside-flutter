import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/application/board_post_store.dart';
import 'package:boulderside_flutter/src/features/community/application/comment_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BoardDetailArguments {
  final BoardPost? post;
  final int? scrollToCommentId;

  const BoardDetailArguments({this.post, this.scrollToCommentId});
}

class BoardDetailPage extends ConsumerStatefulWidget {
  final BoardPost? post;
  final int? scrollToCommentId;
  const BoardDetailPage({super.key, this.post, this.scrollToCommentId});

  @override
  ConsumerState<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends ConsumerState<BoardDetailPage> {
  bool _isMenuOpen = false;
  final ItemScrollController _itemScrollController = ItemScrollController();
  bool _hasScrolledToComment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.post?.id;
      if (id != null) {
        final notifier = ref.read(boardPostStoreProvider.notifier);
        if (widget.post != null) {
          notifier.upsertPost(widget.post!);
        }
        notifier.loadDetail(id);
        ref.read(commentStoreProvider.notifier).loadInitial('board-posts', id);
      }
    });
  }

  void _checkAndScrollToComment(List<CommentResponseModel> comments) {
    if (_hasScrolledToComment || widget.scrollToCommentId == null) return;

    final index = comments.indexWhere(
      (c) => c.commentId == widget.scrollToCommentId,
    );
    if (index != -1) {
      _hasScrolledToComment = true;
      // Index in list is 2 + commentIndex
      // 0: Post, 1: Header, 2: First Comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: index + 2,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  void _showEditCommentDialog(CommentResponseModel comment, int domainId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '댓글 수정',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: CommentInput(
            initialText: comment.content,
            hintText: '댓글을 수정하세요...',
            submitText: '수정',
            isLoading: ref
                .watch(commentFeedProvider(('board-posts', domainId)))
                .isSubmitting,
            onSubmit: (content) async {
              final success = await ref
                  .read(commentStoreProvider.notifier)
                  .editComment(
                    'board-posts',
                    domainId,
                    comment.commentId,
                    content,
                  );
              if (success && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          ),
        ],
      ),
    );
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
          centerTitle: false,
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

    final commentFeed = ref.watch(
      commentFeedProvider(('board-posts', domainId)),
    );
    final commentNotifier = ref.read(commentStoreProvider.notifier);

    _checkAndScrollToComment(commentFeed.comments);

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
          centerTitle: false,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Colors.white,
              ),
              color: const Color(0xFF262A34),
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.pencil,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '수정',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '삭제',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                } else {
                  return const [
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '신고',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
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
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemCount:
                        2 +
                        commentFeed.comments.length +
                        (commentFeed.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Post card
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Card(
                            color: const Color(0xFF262A34),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        authorName,
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          color: Color(0xFFB0B3B8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          '•',
                                          style: TextStyle(
                                            color: Color(0xFF7C7C7C),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatExactDateTime(createdAt),
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          color: Color(0xFF7C7C7C),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    boardTitle,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    height: 1,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    content.isNotEmpty
                                        ? content
                                        : '작성된 본문이 없습니다.',
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: Colors.white,
                                      fontSize: 15,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
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
                                        '$commentCount',
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
                                        '$viewCount',
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
                        );
                      }
                      // Comment header
                      else if (index == 1) {
                        return Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            20,
                            16,
                            20,
                            12,
                          ),
                          color: const Color(0xFF181A20),
                          child: Row(
                            children: [
                              const Text(
                                '댓글',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${commentFeed.comments.length}',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  color: Color(0xFFFF3278),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // Comments or loading indicator
                      else {
                        final commentIndex = index - 2;
                        if (commentIndex < commentFeed.comments.length) {
                          final comment = commentFeed.comments[commentIndex];
                          return CommentCard(
                            comment: comment,
                            onEdit: () =>
                                _showEditCommentDialog(comment, domainId),
                            onDelete: () async {
                              final success = await commentNotifier
                                  .deleteComment(
                                    'board-posts',
                                    domainId,
                                    comment.commentId,
                                  );
                              if (success && mounted) {
                                final currentCount =
                                    postDetail?.commentCount ??
                                    fallback.commentCount;
                                ref
                                    .read(boardPostStoreProvider.notifier)
                                    .updateCommentCount(
                                      domainId,
                                      currentCount > 0 ? currentCount - 1 : 0,
                                    );
                              }
                            },
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF3278),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                CommentInput(
                  hintText: '댓글을 입력하세요...',
                  submitText: '등록',
                  isLoading: commentFeed.isSubmitting,
                  onSubmit: (content) async {
                    final result = await commentNotifier.addComment(
                      'board-posts',
                      domainId,
                      content,
                    );
                    if (result != null && mounted) {
                      ref
                          .read(boardPostStoreProvider.notifier)
                          .updateCommentCount(domainId, result.commentCount);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
