import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/general_post_sort_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoardPostStore extends StateNotifier<BoardPostStoreState> {
  BoardPostStore(this._service) : super(const BoardPostStoreState());

  final BoardPostService _service;
  static const int _pageSize = 5;

  String _key(GeneralPostSortOption sort) => 'board_${sort.name}';

  BoardPostFeedState _feed(GeneralPostSortOption sort) {
    final key = _key(sort);
    return state.feeds[key] ?? const BoardPostFeedState();
  }

  void _setFeed(GeneralPostSortOption sort, BoardPostFeedState feed) {
    final key = _key(sort);
    final feeds = Map<String, BoardPostFeedState>.from(state.feeds)
      ..[key] = feed;
    state = state.copyWith(feeds: feeds);
  }

  void _upsertPosts(List<BoardPost> posts) {
    if (posts.isEmpty) return;
    final entities = Map<int, BoardPost>.from(state.entities);
    for (final post in posts) {
      entities[post.id] = post;
    }
    state = state.copyWith(entities: entities);
  }

  BoardPostDetailState _detail(int id) {
    return state.details[id] ?? const BoardPostDetailState();
  }

  void _setDetail(int id, BoardPostDetailState detail) {
    final details = Map<int, BoardPostDetailState>.from(state.details)
      ..[id] = detail;
    state = state.copyWith(details: details);
  }

  void _removePost(int id) {
    final entities = Map<int, BoardPost>.from(state.entities)..remove(id);
    final feeds = <String, BoardPostFeedState>{};
    state.feeds.forEach((key, feed) {
      feeds[key] = feed.copyWith(
        ids: feed.ids.where((element) => element != id).toList(),
      );
    });
    final details = Map<int, BoardPostDetailState>.from(state.details)
      ..remove(id);
    state = state.copyWith(entities: entities, feeds: feeds, details: details);
  }

  List<int> _mergeIds(
    List<int> current,
    List<BoardPost> next, {
    bool reset = false,
  }) {
    if (reset) {
      return next.map((post) => post.id).toList();
    }
    final ids = List<int>.from(current);
    final seen = current.toSet();
    for (final post in next) {
      if (seen.add(post.id)) {
        ids.add(post.id);
      }
    }
    return ids;
  }

  Future<void> loadInitial(GeneralPostSortOption sort) async {
    final feed = _feed(sort);
    _setFeed(sort, feed.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await _service.fetchPosts(
        cursor: null,
        subCursor: null,
        size: _pageSize,
        sort: _mapSort(sort),
      );
      final posts = response.content.map((e) => e.toBoardPost()).toList();
      _upsertPosts(posts);
      _setFeed(
        sort,
        feed.copyWith(
          ids: _mergeIds(feed.ids, posts, reset: true),
          nextCursor: response.nextCursor,
          nextSubCursor: response.nextSubCursor,
          hasNext: response.hasNext,
          isLoading: false,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _setFeed(
        sort,
        feed.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: '게시글을 불러오지 못했습니다.',
        ),
      );
    }
  }

  Future<void> loadMore(GeneralPostSortOption sort) async {
    final feed = _feed(sort);
    if (feed.isLoading || feed.isLoadingMore || !feed.hasNext) return;

    _setFeed(sort, feed.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final response = await _service.fetchPosts(
        cursor: feed.nextCursor,
        subCursor: feed.nextSubCursor,
        size: _pageSize,
        sort: _mapSort(sort),
      );
      final posts = response.content.map((e) => e.toBoardPost()).toList();
      _upsertPosts(posts);
      _setFeed(
        sort,
        feed.copyWith(
          ids: _mergeIds(feed.ids, posts),
          nextCursor: response.nextCursor,
          nextSubCursor: response.nextSubCursor,
          hasNext: response.hasNext,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _setFeed(
        sort,
        feed.copyWith(isLoadingMore: false, errorMessage: '게시글을 불러오지 못했습니다.'),
      );
    }
  }

  Future<void> refresh(GeneralPostSortOption sort) => loadInitial(sort);

  Future<void> loadDetail(int id, {bool forceRefresh = false}) async {
    if (id == 0) return;
    final detail = _detail(id);
    if (detail.data != null && !forceRefresh) return;

    _setDetail(id, detail.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await _service.fetchPost(id);
      _upsertPosts([response.toBoardPost()]);
      _setDetail(
        id,
        detail.copyWith(data: response, isLoading: false, errorMessage: null),
      );
    } catch (error) {
      _setDetail(
        id,
        detail.copyWith(isLoading: false, errorMessage: '게시글을 불러오지 못했습니다.'),
      );
    }
  }

  Future<BoardPostResponse> createPost(CreateBoardPostRequest request) async {
    final response = await _service.createPost(request);
    _upsertPosts([response.toBoardPost()]);
    _setDetail(response.boardPostId, BoardPostDetailState(data: response));
    return response;
  }

  Future<BoardPostResponse> updatePost(
    int id,
    UpdateBoardPostRequest request,
  ) async {
    final response = await _service.updatePost(id, request);
    _upsertPosts([response.toBoardPost()]);
    _setDetail(id, BoardPostDetailState(data: response));
    return response;
  }

  Future<void> deletePost(int id) async {
    await _service.deletePost(id);
    _removePost(id);
  }

  BoardPostSort _mapSort(GeneralPostSortOption sort) {
    switch (sort) {
      case GeneralPostSortOption.latest:
        return BoardPostSort.latestCreated;
      case GeneralPostSortOption.mostViewed:
        return BoardPostSort.mostViewed;
    }
  }
}

class BoardPostStoreState {
  const BoardPostStoreState({
    this.entities = const <int, BoardPost>{},
    this.feeds = const <String, BoardPostFeedState>{},
    this.details = const <int, BoardPostDetailState>{},
  });

  final Map<int, BoardPost> entities;
  final Map<String, BoardPostFeedState> feeds;
  final Map<int, BoardPostDetailState> details;

  BoardPostStoreState copyWith({
    Map<int, BoardPost>? entities,
    Map<String, BoardPostFeedState>? feeds,
    Map<int, BoardPostDetailState>? details,
  }) {
    return BoardPostStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
      details: details ?? this.details,
    );
  }
}

const _sentinel = Object();

class BoardPostFeedState {
  const BoardPostFeedState({
    this.ids = const <int>[],
    this.nextCursor,
    this.nextSubCursor,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<int> ids;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  BoardPostFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    Object? nextSubCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return BoardPostFeedState(
      ids: ids ?? this.ids,
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as int?,
      nextSubCursor: identical(nextSubCursor, _sentinel)
          ? this.nextSubCursor
          : nextSubCursor as String?,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class BoardPostFeedViewData {
  const BoardPostFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<BoardPost> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final boardPostServiceProvider = Provider<BoardPostService>(
  (ref) => di<BoardPostService>(),
);

final boardPostStoreProvider =
    StateNotifierProvider<BoardPostStore, BoardPostStoreState>((ref) {
      return BoardPostStore(ref.watch(boardPostServiceProvider));
    });

final boardPostFeedProvider =
    Provider.family<BoardPostFeedViewData, GeneralPostSortOption>((ref, sort) {
      final state = ref.watch(boardPostStoreProvider);
      final key = 'board_${sort.name}';
      final feed = state.feeds[key] ?? const BoardPostFeedState();
      final items = feed.ids
          .map((id) => state.entities[id])
          .whereType<BoardPost>()
          .toList();
      final isInitialLoading = feed.isLoading && items.isEmpty;
      return BoardPostFeedViewData(
        items: items,
        isLoading: feed.isLoading,
        isInitialLoading: isInitialLoading,
        isLoadingMore: feed.isLoadingMore,
        hasNext: feed.hasNext,
        errorMessage: feed.errorMessage,
      );
    });

class BoardPostDetailState {
  const BoardPostDetailState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final BoardPostResponse? data;
  final bool isLoading;
  final String? errorMessage;

  BoardPostDetailState copyWith({
    BoardPostResponse? data,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return BoardPostDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class BoardPostDetailViewData {
  const BoardPostDetailViewData({
    required this.detail,
    required this.fallback,
    required this.isLoading,
    required this.errorMessage,
  });

  final BoardPostResponse? detail;
  final BoardPost? fallback;
  final bool isLoading;
  final String? errorMessage;
}

final boardPostDetailProvider = Provider.family<BoardPostDetailViewData, int>((
  ref,
  id,
) {
  final state = ref.watch(boardPostStoreProvider);
  final detailState = state.details[id] ?? const BoardPostDetailState();
  return BoardPostDetailViewData(
    detail: detailState.data,
    fallback: state.entities[id],
    isLoading: detailState.isLoading,
    errorMessage: detailState.errorMessage,
  );
});
