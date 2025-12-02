import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_board_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_mate_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_board_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_mate_posts_use_case.dart';
import 'package:flutter/foundation.dart';

enum MyPostsTab { mate, board }

class MyPostsViewModel extends ChangeNotifier {
  MyPostsViewModel(this._fetchBoardPosts, this._fetchMatePosts);

  final FetchMyBoardPostsUseCase _fetchBoardPosts;
  final FetchMyMatePostsUseCase _fetchMatePosts;

  final _PostListState<BoardPostResponse> _boardState = _PostListState<BoardPostResponse>();
  final _PostListState<MatePostResponse> _mateState = _PostListState<MatePostResponse>();

  List<BoardPost> get boardPosts => _boardState.posts.map((post) => post.toBoardPost()).toList();

  List<CompanionPost> get companionPosts => _mateState.posts.map((post) => post.toCompanionPost()).toList();

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
        final result = await _fetchBoardPosts(cursor: state.nextCursor);
        result.when(
          success: (page) => _applyBoardResponse(page, append: false),
          failure: (failure) => state.errorMessage = failure.message,
        );
      } else {
        final result = await _fetchMatePosts(cursor: state.nextCursor);
        result.when(
          success: (page) => _applyMateResponse(page, append: false),
          failure: (failure) => state.errorMessage = failure.message,
        );
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
        final result = await _fetchBoardPosts(cursor: state.nextCursor);
        result.when(
          success: (page) => _applyBoardResponse(page, append: true),
          failure: (failure) => state.errorMessage = failure.message,
        );
      } else {
        final result = await _fetchMatePosts(cursor: state.nextCursor);
        result.when(
          success: (page) => _applyMateResponse(page, append: true),
          failure: (failure) => state.errorMessage = failure.message,
        );
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

  _PostListState<dynamic> _state(MyPostsTab type) => type == MyPostsTab.board ? _boardState : _mateState;

  void _applyBoardResponse(MyBoardPostsPage response, {required bool append}) {
    if (!append) {
      _boardState.posts
        ..clear()
        ..addAll(response.items);
    } else {
      _boardState.posts.addAll(response.items);
    }
    _boardState.nextCursor = response.nextCursor;
    _boardState.hasNext = response.hasNext;
  }

  void _applyMateResponse(MyMatePostsPage response, {required bool append}) {
    if (!append) {
      _mateState.posts
        ..clear()
        ..addAll(response.items);
    } else {
      _mateState.posts.addAll(response.items);
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
