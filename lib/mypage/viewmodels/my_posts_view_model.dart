import 'package:boulderside_flutter/community/models/board_post.dart';
import 'package:boulderside_flutter/community/models/companion_post.dart';
import 'package:boulderside_flutter/community/models/board_post_models.dart';
import 'package:boulderside_flutter/community/models/mate_post_models.dart';
import 'package:boulderside_flutter/mypage/services/my_posts_service.dart';
import 'package:flutter/foundation.dart';

enum MyPostsTab {
  mate,
  board,
}

class MyPostsViewModel extends ChangeNotifier {
  MyPostsViewModel(this._service);

  final MyPostsService _service;

  final _PostListState<BoardPostResponse> _boardState =
      _PostListState<BoardPostResponse>();
  final _PostListState<MatePostResponse> _mateState =
      _PostListState<MatePostResponse>();

  List<BoardPost> get boardPosts =>
      _boardState.posts.map((post) => post.toBoardPost()).toList();

  List<CompanionPost> get companionPosts =>
      _mateState.posts.map((post) => post.toCompanionPost()).toList();

  bool isLoading(MyPostsTab type) => _state(type).isLoading;
  bool isLoadingMore(MyPostsTab type) => _state(type).isLoadingMore;
  bool hasNext(MyPostsTab type) => _state(type).hasNext;
  String? errorMessage(MyPostsTab type) => _state(type).errorMessage;

  Future<void> loadInitial(MyPostsTab type) async {
    final state = _state(type);
    state
      ..posts.clear()
      ..hasNext = true
      ..nextCursor = null
      ..errorMessage = null
      ..isLoading = true;
    notifyListeners();

    try {
      if (type == MyPostsTab.board) {
        final response = await _service.fetchMyBoardPosts(cursor: state.nextCursor);
        _applyBoardResponse(response, append: false);
      } else {
        final response = await _service.fetchMyMatePosts(cursor: state.nextCursor);
        _applyMateResponse(response, append: false);
      }
      state.initialized = true;
    } catch (e) {
      debugPrint('Failed to load my ${type.name} posts: $e');
      state.errorMessage = '내 게시글을 불러올 수 없습니다.';
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(MyPostsTab type) => loadInitial(type);

  Future<void> loadMore(MyPostsTab type) async {
    final state = _state(type);
    if (state.isLoadingMore || !state.hasNext) return;
    state.isLoadingMore = true;
    notifyListeners();

    try {
      if (type == MyPostsTab.board) {
        final response = await _service.fetchMyBoardPosts(cursor: state.nextCursor);
        _applyBoardResponse(response, append: true);
      } else {
        final response = await _service.fetchMyMatePosts(cursor: state.nextCursor);
        _applyMateResponse(response, append: true);
      }
    } catch (e) {
      debugPrint('Failed to load more ${type.name} posts: $e');
      state.errorMessage = '더 불러오지 못했습니다.';
    } finally {
      state.isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> ensurePrefetched(MyPostsTab type) async {
    final state = _state(type);
    if (state.initialized || state.isLoading) return;
    await loadInitial(type);
  }

  _PostListState<dynamic> _state(MyPostsTab type) =>
      type == MyPostsTab.board ? _boardState : _mateState;

  void _applyBoardResponse(
    BoardPostPageResponse response, {
    required bool append,
  }) {
    if (!append) {
      _boardState.posts
        ..clear()
        ..addAll(response.content);
    } else {
      _boardState.posts.addAll(response.content);
    }
    _boardState.nextCursor = response.nextCursor;
    _boardState.hasNext = response.hasNext;
  }

  void _applyMateResponse(
    MatePostPageResponse response, {
    required bool append,
  }) {
    if (!append) {
      _mateState.posts
        ..clear()
        ..addAll(response.content);
    } else {
      _mateState.posts.addAll(response.content);
    }
    _mateState.nextCursor = response.nextCursor;
    _mateState.hasNext = response.hasNext;
  }
}

class _PostListState<T> {
  final List<T> posts = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasNext = true;
  int? nextCursor;
  String? errorMessage;
  bool initialized = false;
}
