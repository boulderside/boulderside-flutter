import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';

class CommentListViewModel extends ChangeNotifier {
  final CommentService _service;

  CommentListViewModel(this._service);

  final List<CommentResponseModel> comments = [];

  String _domainType = '';
  int _domainId = 0;
  int nextCursor = 0;
  bool hasNext = true;
  bool isLoading = false;
  String? error;
  final int pageSize = 10;

  String get domainType => _domainType;
  int get domainId => _domainId;

  /// 첫 페이지 로드(리셋 후 로드)
  Future<void> loadInitial(String domainType, int domainId) async {
    debugPrint(
      'CommentListViewModel.loadInitial - Starting initial load for $domainType/$domainId with pageSize: $pageSize',
    );
    _domainType = domainType;
    _domainId = domainId;
    nextCursor = 0;
    hasNext = true;
    error = null;
    comments.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext || _domainType.isEmpty || _domainId == 0) return;

    debugPrint(
      'CommentListViewModel.loadMore - cursor: $nextCursor, pageSize: $pageSize',
    );

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.getComments(
        domainType: _domainType,
        domainId: _domainId,
        cursor: nextCursor == 0 ? null : nextCursor,
        size: pageSize,
      );

      debugPrint(
        'CommentListViewModel.loadMore - Received ${response.content.length} comments (expected: $pageSize), hasNext: ${response.hasNext}',
      );

      comments.addAll(response.content);
      nextCursor = response.nextCursor;
      hasNext = response.hasNext;
    } catch (e) {
      debugPrint('fetchComments error: $e');
      error = e.toString();
      // On error, ensure we can try again by resetting loading state
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 당겨서 새로고침 동일 동작
  Future<void> refresh() async {
    if (_domainType.isNotEmpty && _domainId != 0) {
      await loadInitial(_domainType, _domainId);
    }
  }

  /// 새 댓글 추가
  Future<void> addComment(String content) async {
    if (_domainType.isEmpty || _domainId == 0 || content.trim().isEmpty) return;

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final newComment = await _service.createComment(
        domainType: _domainType,
        domainId: _domainId,
        content: content.trim(),
      );

      // 새 댓글을 리스트 맨 앞에 추가
      comments.insert(0, newComment);
      debugPrint(
        'CommentListViewModel.addComment - Added new comment: ${newComment.commentId}',
      );
    } catch (e) {
      debugPrint('addComment error: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 댓글 수정
  Future<void> editComment(int commentId, String content) async {
    if (_domainType.isEmpty || _domainId == 0 || content.trim().isEmpty) return;

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final updatedComment = await _service.updateComment(
        domainType: _domainType,
        domainId: _domainId,
        commentId: commentId,
        content: content.trim(),
      );

      // 기존 댓글을 업데이트된 댓글로 교체
      final index = comments.indexWhere((c) => c.commentId == commentId);
      if (index != -1) {
        comments[index] = updatedComment;
        debugPrint(
          'CommentListViewModel.editComment - Updated comment: $commentId',
        );
      }
    } catch (e) {
      debugPrint('editComment error: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 댓글 삭제
  Future<void> removeComment(int commentId) async {
    if (_domainType.isEmpty || _domainId == 0) return;

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _service.deleteComment(
        domainType: _domainType,
        domainId: _domainId,
        commentId: commentId,
      );

      // 댓글을 리스트에서 제거
      comments.removeWhere((c) => c.commentId == commentId);
      debugPrint(
        'CommentListViewModel.removeComment - Removed comment: $commentId',
      );
    } catch (e) {
      debugPrint('removeComment error: $e');
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 오류 메시지 클리어
  void clearError() {
    error = null;
    notifyListeners();
  }
}
