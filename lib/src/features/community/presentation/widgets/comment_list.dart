import 'package:boulderside_flutter/src/features/community/application/comment_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'comment_card.dart';
import 'comment_input.dart';

class CommentList extends ConsumerStatefulWidget {
  final String domainType;
  final int domainId;

  const CommentList({
    super.key,
    required this.domainType,
    required this.domainId,
  });

  @override
  ConsumerState<CommentList> createState() => _CommentListState();
}

class _CommentListState extends ConsumerState<CommentList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentStoreProvider.notifier)
          .loadInitial(widget.domainType, widget.domainId);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final feed = ref.read(
      commentFeedProvider((widget.domainType, widget.domainId)),
    );
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !feed.isLoading &&
        feed.hasNext) {
      ref
          .read(commentStoreProvider.notifier)
          .loadMore(widget.domainType, widget.domainId);
    }
  }

  void _showEditDialog(CommentResponseModel comment) {
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
                .watch(
                  commentFeedProvider((widget.domainType, widget.domainId)),
                )
                .isSubmitting,
            onSubmit: (content) {
              ref
                  .read(commentStoreProvider.notifier)
                  .editComment(
                    widget.domainType,
                    widget.domainId,
                    comment.commentId,
                    content,
                  );
              context.pop();
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

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(commentStoreProvider.notifier);
    final feed = ref.watch(
      commentFeedProvider((widget.domainType, widget.domainId)),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
          decoration: const BoxDecoration(
            color: Color(0xFF181A20),
            border: Border(
              bottom: BorderSide(color: Color(0xFF262A34), width: 1),
            ),
          ),
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
                '${feed.comments.length}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: Color(0xFFFF3278),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: feed.isInitialLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF3278)),
                )
              : feed.comments.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      '첫 번째 댓글을 남겨보세요!',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      feed.comments.length + (feed.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < feed.comments.length) {
                      final comment = feed.comments[index];
                      return CommentCard(
                        comment: comment,
                        onEdit: () => _showEditDialog(comment),
                        onDelete: () => notifier.deleteComment(
                          widget.domainType,
                          widget.domainId,
                          comment.commentId,
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
                  },
                ),
        ),
        if (feed.errorMessage != null)
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    feed.errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      notifier.loadInitial(widget.domainType, widget.domainId),
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFFFF3278),
                    ),
                  ),
                ),
              ],
            ),
          ),
        CommentInput(
          hintText: '댓글을 입력하세요...',
          submitText: '등록',
          isLoading: feed.isSubmitting,
          onSubmit: (content) =>
              notifier.addComment(widget.domainType, widget.domainId, content),
        ),
      ],
    );
  }
}
