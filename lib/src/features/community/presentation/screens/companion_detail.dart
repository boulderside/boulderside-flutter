import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/application/companion_post_store.dart';
import 'package:boulderside_flutter/src/features/community/application/comment_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/comment_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/report_target_type.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/report_create_screen.dart';

class CompanionDetailArguments {
  final CompanionPost? post;
  final int? scrollToCommentId;

  const CompanionDetailArguments({this.post, this.scrollToCommentId});
}

class CompanionDetailPage extends ConsumerStatefulWidget {
  final CompanionPost? post;
  final int? scrollToCommentId;
  const CompanionDetailPage({super.key, this.post, this.scrollToCommentId});

  @override
  ConsumerState<CompanionDetailPage> createState() =>
      _CompanionDetailPageState();
}

class _CompanionDetailPageState extends ConsumerState<CompanionDetailPage> {
  bool _isMenuOpen = false;
  final ItemScrollController _itemScrollController = ItemScrollController();
  bool _hasScrolledToComment = false;

  String _summarize(String text) {
    const limit = 150;
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}…';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.post?.id;
      if (id != null) {
        ref.read(companionPostStoreProvider.notifier).loadDetail(id);
        ref.read(commentStoreProvider.notifier).loadInitial('mate-posts', id);
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
                .watch(commentFeedProvider(('mate-posts', domainId)))
                .isSubmitting,
            onSubmit: (content) async {
              final success = await ref
                  .read(commentStoreProvider.notifier)
                  .editComment(
                    'mate-posts',
                    domainId,
                    comment.commentId,
                    content,
                  );
              if (success && context.mounted) {
                // 댓글 수정은 게시글의 댓글 수나 기타 정보에 영향을 주지 않으므로
                // 전체 리로드(loadDetail)를 하지 않고 팝업만 닫습니다.
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

  String _formatMeetingDate(DateTime date) {
    final weekdayKorean = _getKoreanWeekday(date.weekday);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ($weekdayKorean)';
  }

  String _getKoreanWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  void _editPost(MatePostResponse post) {
    context
        .push<MatePostResponse>(AppRoutes.communityCompanionCreate, extra: post)
        .then((updated) {
          if (!mounted || widget.post == null) return;
          if (updated != null) {
            ref
                .read(companionPostStoreProvider.notifier)
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
        await ref.read(companionPostStoreProvider.notifier).deletePost(postId);
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

  Future<void> _reportContent({
    required ReportTargetType targetType,
    required int targetId,
    required String title,
    String? contextInfo,
    String? contextSummary,
  }) async {
    if (targetId == 0) return;
    await context.push<bool>(
      AppRoutes.reportCreate,
      extra: ReportCreateArgs(
        targetType: targetType,
        targetId: targetId,
        targetTitle: title,
        contextInfo: contextInfo,
        contextSummary: contextSummary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post?.id;
    final detail = postId != null
        ? ref.watch(companionPostDetailProvider(postId))
        : const CompanionPostDetailViewData(
            detail: null,
            fallback: null,
            isLoading: false,
            errorMessage: '동행 글 정보를 찾을 수 없습니다.',
          );
    final fallback =
        widget.post ??
        detail.fallback ??
        CompanionPost(
          id: 0,
          title: '동행 상세',
          meetingPlace: '서울특별시',
          meetingDateLabel: '2025.08.02 (Sat)',
          authorNickname: 'guest',
          commentCount: 0,
          viewCount: 0,
          createdAt: DateTime.now(),
          content: '동행 글 내용이 없습니다.',
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
    final meetingDate = postDetail?.meetingDate;
    final meetingDateLabel = meetingDate != null
        ? _formatMeetingDate(meetingDate)
        : fallback.meetingDateLabel;
    final viewCount = postDetail?.viewCount ?? fallback.viewCount;
    final commentCount = postDetail?.commentCount ?? fallback.commentCount;
    final authorName = postDetail?.userInfo.nickname ?? fallback.authorNickname;
    final title = postDetail?.title ?? fallback.title;
    final content = postDetail?.content ?? fallback.content ?? '';
    final createdAt = postDetail?.createdAt ?? fallback.createdAt;
    final domainId = postDetail?.matePostId ?? fallback.id;

    final commentFeed = ref.watch(
      commentFeedProvider(('mate-posts', domainId)),
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
                    _reportContent(
                      targetType: ReportTargetType.matePost,
                      targetId: domainId,
                      title: '동행 글 신고',
                      contextInfo: '동행 글 제목: $title\n내용: $content',
                      contextSummary: _summarize(content),
                    );
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
                                    title,
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.calendar,
                                          size: 13,
                                          color: Color(0xFFB0B3B8),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          meetingDateLabel,
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            color: Color(0xFFB0B3B8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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
                                    'mate-posts',
                                    domainId,
                                    comment.commentId,
                                  );
                              if (success && mounted) {
                                final currentCount =
                                    postDetail?.commentCount ??
                                    fallback.commentCount;
                                ref
                                    .read(companionPostStoreProvider.notifier)
                                    .updateCommentCount(
                                      domainId,
                                      currentCount > 0 ? currentCount - 1 : 0,
                                    );
                              }
                            },
                            onReport: comment.isMine
                                ? null
                                : () => _reportContent(
                                      targetType: ReportTargetType.comment,
                                      targetId: comment.commentId,
                                      title: '댓글 신고',
                                      contextInfo:
                                          '동행 글: $title\n작성자: ${comment.userInfo.nickname}\n내용: ${comment.content}',
                                      contextSummary:
                                          _summarize(comment.content),
                                    ),
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
                      'mate-posts',
                      domainId,
                      content,
                    );
                    if (result != null && mounted) {
                      ref
                          .read(companionPostStoreProvider.notifier)
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
