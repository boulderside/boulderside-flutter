import 'package:boulderside_flutter/community/models/board_post.dart';
import 'package:boulderside_flutter/community/models/companion_post.dart';
import 'package:boulderside_flutter/community/models/post_models.dart';
import 'package:boulderside_flutter/mypage/services/my_posts_service.dart';
import 'package:flutter/foundation.dart';

class MyPostsViewModel extends ChangeNotifier {
  MyPostsViewModel(this._service);

  final MyPostsService _service;
  static const int _pageSize = 10;

  final List<PostResponse> _posts = <PostResponse>[];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasNext = true;
  int? _nextCursor;
  String? _errorMessage;
  bool _isEnsuring = false;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasNext => _hasNext;
  String? get errorMessage => _errorMessage;

  List<BoardPost> get boardPosts => _posts
      .where((post) => post.postType == PostType.board)
      .map((post) => post.toBoardPost())
      .toList();

  List<CompanionPost> get companionPosts => _posts
      .where((post) => post.postType == PostType.mate)
      .map((post) => post.toCompanionPost())
      .toList();

  Future<void> loadInitial() async {
    _posts.clear();
    _hasNext = true;
    _nextCursor = null;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchMyPosts(cursor: _nextCursor);
      _applyResponse(response);
    } catch (e) {
      debugPrint('Failed to load my posts: $e');
      _errorMessage = '내 게시글을 불러올 수 없습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNext) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final response = await _service.fetchMyPosts(cursor: _nextCursor);
      _applyResponse(response, append: true);
    } catch (e) {
      debugPrint('Failed to load more posts: $e');
      _errorMessage = '더 불러오지 못했습니다.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void _applyResponse(PostPageResponse response, {bool append = false}) {
    if (!append) {
      _posts
        ..clear()
        ..addAll(response.content);
    } else {
      _posts.addAll(response.content);
    }
    _nextCursor = response.nextCursor;
    _hasNext = response.hasNext;
  }

  Future<void> ensurePrefetched(PostType type) async {
    if (_isEnsuring) return;
    _isEnsuring = true;
    try {
      while (_hasNext && _countForType(type) < _pageSize) {
        await loadMore();
      }
    } finally {
      _isEnsuring = false;
    }
  }

  int _countForType(PostType type) =>
      _posts.where((post) => post.postType == type).length;
}
