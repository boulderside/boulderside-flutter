import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
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
  });

  final Map<int, BoardPost> entities;
  final Map<String, BoardPostFeedState> feeds;

  BoardPostStoreState copyWith({
    Map<int, BoardPost>? entities,
    Map<String, BoardPostFeedState>? feeds,
  }) {
    return BoardPostStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
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
