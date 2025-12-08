import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_board_posts_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_my_mate_posts_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MyPostsTab { mate, board }

class MyPostsStore extends StateNotifier<MyPostsState> {
  MyPostsStore(this._fetchBoardPosts, this._fetchMatePosts)
    : super(const MyPostsState());

  final FetchMyBoardPostsUseCase _fetchBoardPosts;
  final FetchMyMatePostsUseCase _fetchMatePosts;
  static const int _pageSize = 10;

  Future<void> loadInitial(MyPostsTab tab) async {
    final feed = _feed(tab);
    _setFeed(tab, feed.copyWith(isLoading: true, errorMessage: null));
    switch (tab) {
      case MyPostsTab.board:
        await _loadBoard(tab, reset: true);
        break;
      case MyPostsTab.mate:
        await _loadMate(tab, reset: true);
        break;
    }
  }

  Future<void> loadMore(MyPostsTab tab) async {
    final feed = _feed(tab);
    if (feed.isLoading || feed.isLoadingMore || !feed.hasNext) return;
    _setFeed(tab, feed.copyWith(isLoadingMore: true, errorMessage: null));
    switch (tab) {
      case MyPostsTab.board:
        await _loadBoard(tab, reset: false);
        break;
      case MyPostsTab.mate:
        await _loadMate(tab, reset: false);
        break;
    }
  }

  Future<void> refresh(MyPostsTab tab) => loadInitial(tab);

  Future<void> _loadBoard(MyPostsTab tab, {required bool reset}) async {
    final feed = _feed(tab);
    final result = await _fetchBoardPosts(
      cursor: reset ? null : feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        final posts = page.items.map((e) => e.toBoardPost()).toList();
        _upsertBoard(posts, reset: reset);
        _setFeed(
          tab,
          feed.copyWith(
            ids: _mergeIds(feed.ids, posts, reset: reset),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          tab,
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> _loadMate(MyPostsTab tab, {required bool reset}) async {
    final feed = _feed(tab);
    final result = await _fetchMatePosts(
      cursor: reset ? null : feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        final posts = page.items.map((e) => e.toCompanionPost()).toList();
        _upsertMate(posts, reset: reset);
        _setFeed(
          tab,
          feed.copyWith(
            ids: _mergeIds(feed.ids, posts, reset: reset),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          tab,
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  MyPostsFeedState _feed(MyPostsTab tab) {
    return tab == MyPostsTab.board ? state.boardFeed : state.mateFeed;
  }

  void _setFeed(MyPostsTab tab, MyPostsFeedState feed) {
    state = tab == MyPostsTab.board
        ? state.copyWith(boardFeed: feed)
        : state.copyWith(mateFeed: feed);
  }

  void _upsertBoard(List<BoardPost> posts, {required bool reset}) {
    if (posts.isEmpty) return;
    final entities = reset
        ? <int, BoardPost>{}
        : Map<int, BoardPost>.from(state.boardEntities);
    for (final post in posts) {
      entities[post.id] = post;
    }
    state = state.copyWith(boardEntities: entities);
  }

  void _upsertMate(List<CompanionPost> posts, {required bool reset}) {
    if (posts.isEmpty) return;
    final entities = reset
        ? <int, CompanionPost>{}
        : Map<int, CompanionPost>.from(state.mateEntities);
    for (final post in posts) {
      entities[post.id] = post;
    }
    state = state.copyWith(mateEntities: entities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<dynamic> next, {
    required bool reset,
  }) {
    if (reset) {
      return next.map((post) => post.id as int).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final post in next) {
      final int id = post.id as int;
      if (seen.add(id)) {
        ids.add(id);
      }
    }
    return ids;
  }
}

class MyPostsState {
  const MyPostsState({
    this.boardEntities = const <int, BoardPost>{},
    this.mateEntities = const <int, CompanionPost>{},
    this.boardFeed = const MyPostsFeedState(),
    this.mateFeed = const MyPostsFeedState(),
  });

  final Map<int, BoardPost> boardEntities;
  final Map<int, CompanionPost> mateEntities;
  final MyPostsFeedState boardFeed;
  final MyPostsFeedState mateFeed;

  MyPostsState copyWith({
    Map<int, BoardPost>? boardEntities,
    Map<int, CompanionPost>? mateEntities,
    MyPostsFeedState? boardFeed,
    MyPostsFeedState? mateFeed,
  }) {
    return MyPostsState(
      boardEntities: boardEntities ?? this.boardEntities,
      mateEntities: mateEntities ?? this.mateEntities,
      boardFeed: boardFeed ?? this.boardFeed,
      mateFeed: mateFeed ?? this.mateFeed,
    );
  }
}

const _sentinel = Object();

class MyPostsFeedState {
  const MyPostsFeedState({
    this.ids = const <int>[],
    this.nextCursor,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<int> ids;
  final int? nextCursor;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  MyPostsFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return MyPostsFeedState(
      ids: ids ?? this.ids,
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as int?,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class MyPostsFeedViewData<T> {
  const MyPostsFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<T> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final fetchMyBoardPostsUseCaseProvider = Provider<FetchMyBoardPostsUseCase>(
  (ref) => di<FetchMyBoardPostsUseCase>(),
);

final fetchMyMatePostsUseCaseProvider = Provider<FetchMyMatePostsUseCase>(
  (ref) => di<FetchMyMatePostsUseCase>(),
);

final myPostsStoreProvider = StateNotifierProvider<MyPostsStore, MyPostsState>((
  ref,
) {
  return MyPostsStore(
    ref.watch(fetchMyBoardPostsUseCaseProvider),
    ref.watch(fetchMyMatePostsUseCaseProvider),
  );
});

final myBoardPostsFeedProvider = Provider<MyPostsFeedViewData<BoardPost>>((
  ref,
) {
  final state = ref.watch(myPostsStoreProvider);
  final feed = state.boardFeed;
  final items = feed.ids
      .map((id) => state.boardEntities[id])
      .whereType<BoardPost>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return MyPostsFeedViewData<BoardPost>(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});

final myMatePostsFeedProvider = Provider<MyPostsFeedViewData<CompanionPost>>((
  ref,
) {
  final state = ref.watch(myPostsStoreProvider);
  final feed = state.mateFeed;
  final items = feed.ids
      .map((id) => state.mateEntities[id])
      .whereType<CompanionPost>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return MyPostsFeedViewData<CompanionPost>(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});
