import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/comment_list_view_model.dart';
import '../services/comment_service.dart';
import '../models/comment_models.dart';
import 'comment_card.dart';
import 'comment_input.dart';

class CommentList extends StatefulWidget {
  final String domainType;
  final int domainId;

  const CommentList({
    super.key,
    required this.domainType,
    required this.domainId,
  });

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final ScrollController _scrollController = ScrollController();
  CommentListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_viewModel == null) return;
    
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !_viewModel!.isLoading &&
        _viewModel!.hasNext) {
      _viewModel!.loadMore();
    }
  }

  void _showEditDialog(CommentResponseModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '댓글 수정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: CommentInput(
            initialText: comment.content,
            hintText: '댓글을 수정하세요...',
            submitText: '수정',
            isLoading: _viewModel?.isLoading ?? false,
            onSubmit: (content) {
              _viewModel?.editComment(comment.commentId, content);
              Navigator.of(context).pop();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentListViewModel(CommentService())
          ..loadInitial(widget.domainType, widget.domainId),
      child: Consumer<CommentListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;
          
          return Column(
            children: [
              // 댓글 헤더
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF181A20),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF262A34),
                      width: 1,
                    ),
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
                      '${vm.comments.length}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 댓글 리스트
              Expanded(
                child: vm.isLoading && vm.comments.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF3278),
                        ),
                      )
                    : vm.comments.isEmpty
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
                            itemCount: vm.comments.length + (vm.isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < vm.comments.length) {
                                final comment = vm.comments[index];
                                return CommentCard(
                                  comment: comment,
                                  onEdit: () => _showEditDialog(comment),
                                  onDelete: () => vm.removeComment(comment.commentId),
                                );
                              } else {
                                // 로딩 인디케이터
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
              
              // 에러 메시지 표시
              if (vm.error != null)
                Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vm.error!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: vm.clearError,
                        child: const Text(
                          '닫기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 댓글 입력
              CommentInput(
                onSubmit: vm.addComment,
                isLoading: vm.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}