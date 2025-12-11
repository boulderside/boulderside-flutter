import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_detail_service.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_comments_store.dart';
import 'package:boulderside_flutter/src/shared/widgets/segmented_toggle_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyCommentsScreen extends ConsumerStatefulWidget {
  const MyCommentsScreen({super.key});

  @override
  ConsumerState<MyCommentsScreen> createState() => _MyCommentsScreenState();
}

class _MyCommentsScreenState extends ConsumerState<MyCommentsScreen> {
  static const _backgroundColor = Color(0xFF181A20);
  _CommentSegment _segment = _CommentSegment.mate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myCommentsStoreProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(myCommentsFeedProvider);
    final store = ref.read(myCommentsStoreProvider.notifier);
    final filteredItems = feed.items.where(_matchesSegment).toList();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '내 댓글',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        backgroundColor: const Color(0xFF262A34),
        color: const Color(0xFFFF3278),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                feed.hasNext &&
                !feed.isLoadingMore) {
              store.loadMore();
            }
            return false;
          },
          child: Builder(
            builder: (context) {
              final items = filteredItems;

              if (feed.isInitialLoading) {
                return const _LoadingView();
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedToggleBar<_CommentSegment>(
                        options: const [
                          SegmentOption(
                            label: '동행',
                            value: _CommentSegment.mate,
                          ),
                          SegmentOption(
                            label: '게시글',
                            value: _CommentSegment.board,
                          ),
                          SegmentOption(
                            label: '루트',
                            value: _CommentSegment.route,
                          ),
                        ],
                        selectedValue: _segment,
                        onChanged: (segment) {
                          setState(() => _segment = segment);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (feed.errorMessage != null && items.isEmpty) {
                          return _ErrorView(
                            message: feed.errorMessage!,
                            onRetry: store.refresh,
                          );
                        }

                        if (items.isEmpty) {
                          late final String emptyMessage;
                          switch (_segment) {
                            case _CommentSegment.mate:
                              emptyMessage = '동행글에 작성한 댓글이 없습니다.';
                              break;
                            case _CommentSegment.board:
                              emptyMessage = '게시글에 작성한 댓글이 없습니다.';
                              break;
                            case _CommentSegment.route:
                              emptyMessage = '루트에 작성한 댓글이 없습니다.';
                              break;
                          }
                          return _EmptyView(message: emptyMessage);
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ).copyWith(bottom: 24),
                          itemCount:
                              items.length + (feed.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF3278),
                                  ),
                                ),
                              );
                            }
                            final comment = items[index];
                            return _MyCommentCard(
                              comment: comment,
                              onTap: () => _handleCommentTap(comment),
                              onDelete: () => _confirmDelete(context, comment),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CommentResponseModel comment,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF262A34),
              title: const Text(
                '댓글 삭제',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    '삭제',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFFFF3278),
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !mounted) return;

    final success = await ref
        .read(myCommentsStoreProvider.notifier)
        .deleteComment(comment);
    if (!mounted || !context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success ? '댓글을 삭제했습니다.' : '댓글 삭제에 실패했습니다. 잠시 후 다시 시도해주세요.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _handleCommentTap(CommentResponseModel comment) async {
    if (!mounted) return;

    final currentContext = context;

    showDialog<void>(
      context: currentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF3278)),
        );
      },
    );

    try {
      switch (comment.commentDomainType) {
        case CommentDomainType.boardPost:
          final boardPost = await _fetchBoardPost(comment.domainId);
          if (!currentContext.mounted) return;
          await currentContext.push(
            AppRoutes.communityBoardDetail,
            extra: boardPost,
          );
          break;
        case CommentDomainType.matePost:
          final companionPost = await _fetchMatePost(comment.domainId);
          if (!currentContext.mounted) return;
          await currentContext.push(
            AppRoutes.communityCompanionDetail,
            extra: companionPost,
          );
          break;
        case CommentDomainType.route:
          final route = await _fetchRoute(comment.domainId);
          if (!currentContext.mounted) return;
          await currentContext.push(AppRoutes.routeDetail, extra: route);
          break;
      }
    } catch (error) {
      if (!currentContext.mounted) return;
      final messenger = ScaffoldMessenger.of(currentContext);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('대상 콘텐츠를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.\n$error'),
          ),
        );
    } finally {
      if (currentContext.mounted) {
        Navigator.of(currentContext, rootNavigator: true).pop();
      }
    }
  }

  Future<BoardPost> _fetchBoardPost(int postId) async {
    final service = di<BoardPostService>();
    final response = await service.fetchPost(postId);
    return response.toBoardPost();
  }

  Future<CompanionPost> _fetchMatePost(int postId) async {
    final service = di<MatePostService>();
    final response = await service.fetchPost(postId);
    return response.toCompanionPost();
  }

  Future<RouteModel> _fetchRoute(int routeId) async {
    final service = di<RouteDetailService>();
    final detail = await service.fetchDetail(routeId);
    return detail.route;
  }

  bool _matchesSegment(CommentResponseModel comment) {
    switch (_segment) {
      case _CommentSegment.mate:
        return comment.commentDomainType == CommentDomainType.matePost;
      case _CommentSegment.board:
        return comment.commentDomainType == CommentDomainType.boardPost;
      case _CommentSegment.route:
        return comment.commentDomainType == CommentDomainType.route;
    }
  }
}

enum _CommentSegment { mate, board, route }

class _MyCommentCard extends StatelessWidget {
  const _MyCommentCard({
    required this.comment,
    required this.onTap,
    required this.onDelete,
  });

  final CommentResponseModel comment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262A34),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DomainBadge(label: _domainLabel(comment.commentDomainType)),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  tooltip: '댓글 삭제',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.content,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(comment.updatedAt),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _domainLabel(CommentDomainType type) {
    switch (type) {
      case CommentDomainType.boardPost:
        return '커뮤니티 게시글';
      case CommentDomainType.matePost:
        return '동행 모집';
      case CommentDomainType.route:
        return '루트';
    }
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}.${two(local.month)}.${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}

class _DomainBadge extends StatelessWidget {
  const _DomainBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33242734),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF3A3F4E)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF3278)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3278),
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
