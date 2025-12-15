import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_sort_option.dart';
import 'package:boulderside_flutter/src/shared/store/entity_store_mixin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanionPostStore extends StateNotifier<CompanionPostStoreState>
    with EntityStoreMixin<CompanionPost, int> {
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
    state = state.copyWith(
      entities: upsertEntities(state.entities, posts, (p) => p.id),
    );
  }

  CompanionPostDetailState _detail(int id) {
    return state.details[id] ?? const CompanionPostDetailState();
  }

  void _setDetail(int id, CompanionPostDetailState detail) {
    final details = Map<int, CompanionPostDetailState>.from(state.details)
      ..[id] = detail;
    state = state.copyWith(details: details);
  }

  void _removePost(int id) {
    final entities = Map<int, CompanionPost>.from(state.entities)..remove(id);
    final feeds = <String, CompanionFeedState>{};
    state.feeds.forEach((key, feed) {
      feeds[key] = feed.copyWith(
        ids: feed.ids.where((element) => element != id).toList(),
      );
    });
    final details = Map<int, CompanionPostDetailState>.from(state.details)
      ..remove(id);
    state = state.copyWith(entities: entities, feeds: feeds, details: details);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<CompanionPost> next, {
    bool reset = false,
  }) {
    return mergeIds(existing, next, (p) => p.id, reset: reset);
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

  Future<void> loadDetail(int id, {bool forceRefresh = false}) async {
    if (id == 0) return;
    final detail = _detail(id);
    if (detail.data != null && !forceRefresh) return;

    _setDetail(id, detail.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await _service.fetchPost(id);
      _upsertPosts([response.toCompanionPost()]);
      _setDetail(
        id,
        detail.copyWith(data: response, isLoading: false, errorMessage: null),
      );
    } catch (error) {
      _setDetail(
        id,
        detail.copyWith(isLoading: false, errorMessage: '동행 글을 불러오지 못했습니다.'),
      );
    }
  }

  Future<MatePostResponse> createPost(CreateMatePostRequest request) async {
    final response = await _service.createPost(request);
    _upsertPosts([response.toCompanionPost()]);
    _setDetail(response.matePostId, CompanionPostDetailState(data: response));
    return response;
  }

  Future<MatePostResponse> updatePost(
    int id,
    UpdateMatePostRequest request,
  ) async {
    final response = await _service.updatePost(id, request);
    _upsertPosts([response.toCompanionPost()]);
    _setDetail(id, CompanionPostDetailState(data: response));
    return response;
  }

  void updateCommentCount(int id, int count) {
    final entities = Map<int, CompanionPost>.from(state.entities);
    if (entities.containsKey(id)) {
      entities[id] = entities[id]!.copyWith(commentCount: count);
    }

    final details = Map<int, CompanionPostDetailState>.from(state.details);
    if (details.containsKey(id)) {
      final detail = details[id]!;
      if (detail.data != null) {
        details[id] = detail.copyWith(
          data: detail.data!.copyWith(commentCount: count),
        );
      }
    }

    state = state.copyWith(entities: entities, details: details);
  }

  Future<void> deletePost(int id) async {
    await _service.deletePost(id);
    _removePost(id);
  }

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
    this.details = const <int, CompanionPostDetailState>{},
  });

  final Map<int, CompanionPost> entities;
  final Map<String, CompanionFeedState> feeds;
  final Map<int, CompanionPostDetailState> details;

  CompanionPostStoreState copyWith({
    Map<int, CompanionPost>? entities,
    Map<String, CompanionFeedState>? feeds,
    Map<int, CompanionPostDetailState>? details,
  }) {
    return CompanionPostStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
      details: details ?? this.details,
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

class CompanionPostDetailState {
  const CompanionPostDetailState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final MatePostResponse? data;
  final bool isLoading;
  final String? errorMessage;

  CompanionPostDetailState copyWith({
    MatePostResponse? data,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return CompanionPostDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class CompanionPostDetailViewData {
  const CompanionPostDetailViewData({
    required this.detail,
    required this.fallback,
    required this.isLoading,
    required this.errorMessage,
  });

  final MatePostResponse? detail;
  final CompanionPost? fallback;
  final bool isLoading;
  final String? errorMessage;
}

final companionPostDetailProvider =
    Provider.family<CompanionPostDetailViewData, int>((ref, id) {
      final state = ref.watch(companionPostStoreProvider);
      final detailState = state.details[id] ?? const CompanionPostDetailState();
      return CompanionPostDetailViewData(
        detail: detailState.data,
        fallback: state.entities[id],
        isLoading: detailState.isLoading,
        errorMessage: detailState.errorMessage,
      );
    });

final companionPostEntityProvider = Provider.family<CompanionPost?, int>((
  ref,
  id,
) {
  final state = ref.watch(companionPostStoreProvider);
  return state.entities[id];
});
