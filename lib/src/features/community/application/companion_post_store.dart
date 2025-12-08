import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_sort_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanionPostStore extends StateNotifier<CompanionPostStoreState> {
  CompanionPostStore(this._service) : super(const CompanionPostStoreState());

  final MatePostService _service;
  static const int _pageSize = 5;

  String _key(CompanionPostSortOption sort) => 'companion_${sort.name}';

  CompanionFeedState _feed(CompanionPostSortOption sort) {
    final key = _key(sort);
    return state.feeds[key] ?? const CompanionFeedState();
  }

  void _setFeed(CompanionPostSortOption sort, CompanionFeedState feed) {
    final key = _key(sort);
    final feeds = Map<String, CompanionFeedState>.from(state.feeds)
      ..[key] = feed;
    state = state.copyWith(feeds: feeds);
  }

  void _upsertPosts(List<CompanionPost> posts) {
    if (posts.isEmpty) return;
    final entities = Map<int, CompanionPost>.from(state.entities);
    for (final post in posts) {
      entities[post.id] = post;
    }
    state = state.copyWith(entities: entities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<CompanionPost> next, {
    bool reset = false,
  }) {
    if (reset) {
      return next.map((post) => post.id).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final post in next) {
      if (seen.add(post.id)) {
        ids.add(post.id);
      }
    }
    return ids;
  }

  Future<void> loadInitial(CompanionPostSortOption sort) async {
    final feed = _feed(sort);
    _setFeed(sort, feed.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await _service.fetchPosts(
        cursor: null,
        subCursor: null,
        size: _pageSize,
        sort: _mapSort(sort),
      );
      final posts = response.content.map((e) => e.toCompanionPost()).toList();
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
          errorMessage: '동행 글을 불러오지 못했습니다.',
        ),
      );
    }
  }

  Future<void> loadMore(CompanionPostSortOption sort) async {
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
      final posts = response.content.map((e) => e.toCompanionPost()).toList();
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
        feed.copyWith(isLoadingMore: false, errorMessage: '동행 글을 불러오지 못했습니다.'),
      );
    }
  }

  Future<void> refresh(CompanionPostSortOption sort) => loadInitial(sort);

  MatePostSort _mapSort(CompanionPostSortOption sort) {
    switch (sort) {
      case CompanionPostSortOption.latest:
        return MatePostSort.latestCreated;
      case CompanionPostSortOption.mostViewed:
        return MatePostSort.mostViewed;
      case CompanionPostSortOption.companionDate:
        return MatePostSort.nearestMeetingDate;
    }
  }
}

class CompanionPostStoreState {
  const CompanionPostStoreState({
    this.entities = const <int, CompanionPost>{},
    this.feeds = const <String, CompanionFeedState>{},
  });

  final Map<int, CompanionPost> entities;
  final Map<String, CompanionFeedState> feeds;

  CompanionPostStoreState copyWith({
    Map<int, CompanionPost>? entities,
    Map<String, CompanionFeedState>? feeds,
  }) {
    return CompanionPostStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
    );
  }
}

const _sentinel = Object();

class CompanionFeedState {
  const CompanionFeedState({
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

  CompanionFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    Object? nextSubCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return CompanionFeedState(
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

class CompanionFeedViewData {
  const CompanionFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<CompanionPost> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final matePostServiceProvider = Provider<MatePostService>(
  (ref) => di<MatePostService>(),
);

final companionPostStoreProvider =
    StateNotifierProvider<CompanionPostStore, CompanionPostStoreState>((ref) {
      return CompanionPostStore(ref.watch(matePostServiceProvider));
    });

final companionFeedProvider =
    Provider.family<CompanionFeedViewData, CompanionPostSortOption>((
      ref,
      sort,
    ) {
      final state = ref.watch(companionPostStoreProvider);
      final key = 'companion_${sort.name}';
      final feed = state.feeds[key] ?? const CompanionFeedState();
      final items = feed.ids
          .map((id) => state.entities[id])
          .whereType<CompanionPost>()
          .toList();
      final isInitialLoading = feed.isLoading && items.isEmpty;
      return CompanionFeedViewData(
        items: items,
        isLoading: feed.isLoading,
        isInitialLoading: isInitialLoading,
        isLoadingMore: feed.isLoadingMore,
        hasNext: feed.hasNext,
        errorMessage: feed.errorMessage,
      );
    });
