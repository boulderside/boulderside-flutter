import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_rec_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderStore extends StateNotifier<BoulderStoreState> {
  BoulderStore(this._fetchBoulders, this._fetchRecBoulders)
    : super(const BoulderStoreState());

  final FetchBouldersUseCase _fetchBoulders;
  final FetchRecBouldersUseCase _fetchRecBoulders;

  static const String _recommendedKey = 'recommended';
  static const int _pageSize = 5;
  static const String _recommendedSortType = 'LATEST_CREATED';

  String _standardKey(BoulderSortOption sort) => 'standard_${sort.name}';

  BoulderFeedState _standardFeed(BoulderSortOption sort) {
    final key = _standardKey(sort);
    return state.feeds[key] ?? const BoulderFeedState();
  }

  BoulderFeedState _recommendedFeed() {
    return state.feeds[_recommendedKey] ?? const BoulderFeedState();
  }

  void _setFeed(String key, BoulderFeedState feed) {
    final updatedFeeds = Map<String, BoulderFeedState>.from(state.feeds)
      ..[key] = feed;
    state = state.copyWith(feeds: updatedFeeds);
  }

  void _upsertBoulders(List<BoulderModel> boulders) {
    if (boulders.isEmpty) return;
    final updatedEntities = Map<int, BoulderModel>.from(state.entities);
    for (final boulder in boulders) {
      updatedEntities[boulder.id] = boulder;
    }
    state = state.copyWith(entities: updatedEntities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<BoulderModel> nextItems, {
    bool reset = false,
  }) {
    if (reset) {
      return nextItems.map((b) => b.id).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final item in nextItems) {
      if (seen.add(item.id)) {
        ids.add(item.id);
      }
    }
    return ids;
  }

  Future<void> loadInitialStandard(BoulderSortOption sort) async {
    final key = _standardKey(sort);
    final feed = _standardFeed(sort);
    _setFeed(key, feed.copyWith(isLoading: true, errorMessage: null));

    final Result<PaginatedBoulders> result = await _fetchBoulders(
      sortType: sort.name,
      cursor: null,
      subCursor: null,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertBoulders(page.items);
        _setFeed(
          key,
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items, reset: true),
            nextCursor: page.nextCursor,
            nextSubCursor: page.nextSubCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          key,
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> loadMoreStandard(BoulderSortOption sort) async {
    final key = _standardKey(sort);
    final feed = _standardFeed(sort);
    if (!feed.hasNext || feed.isLoading || feed.isLoadingMore) return;

    _setFeed(key, feed.copyWith(isLoadingMore: true, errorMessage: null));

    final Result<PaginatedBoulders> result = await _fetchBoulders(
      sortType: sort.name,
      cursor: feed.nextCursor,
      subCursor: feed.nextSubCursor,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertBoulders(page.items);
        _setFeed(
          key,
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items),
            nextCursor: page.nextCursor,
            nextSubCursor: page.nextSubCursor,
            hasNext: page.hasNext,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          key,
          feed.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
    );
  }

  Future<void> loadInitialRecommended() async {
    final feed = _recommendedFeed();
    _setFeed(
      _recommendedKey,
      feed.copyWith(isLoading: true, errorMessage: null),
    );

    final Result<RecBoulderPage> result = await _fetchRecBoulders(
      sortType: _recommendedSortType,
      cursor: null,
      subCursor: null,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertBoulders(page.items);
        _setFeed(
          _recommendedKey,
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items, reset: true),
            nextCursor: page.nextCursor,
            nextSubCursor: page.nextSubCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          _recommendedKey,
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> loadMoreRecommended() async {
    final feed = _recommendedFeed();
    if (!feed.hasNext || feed.isLoading || feed.isLoadingMore) return;
    _setFeed(
      _recommendedKey,
      feed.copyWith(isLoadingMore: true, errorMessage: null),
    );

    final Result<RecBoulderPage> result = await _fetchRecBoulders(
      sortType: _recommendedSortType,
      cursor: feed.nextCursor,
      subCursor: feed.nextSubCursor,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertBoulders(page.items);
        _setFeed(
          _recommendedKey,
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items),
            nextCursor: page.nextCursor,
            nextSubCursor: page.nextSubCursor,
            hasNext: page.hasNext,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setFeed(
          _recommendedKey,
          feed.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
    );
  }

  void applyLikeResult(LikeToggleResult result) {
    final boulderId = result.boulderId ?? result.targetId;
    if (boulderId == null) return;
    final current = state.entities[boulderId];
    if (current == null) return;
    final updated = current.copyWith(
      liked: result.liked ?? current.liked,
      likeCount: result.likeCount ?? current.likeCount,
    );
    _upsertBoulders([updated]);
  }

  void upsertBoulder(BoulderModel boulder) {
    _upsertBoulders([boulder]);
  }
}

class BoulderStoreState {
  const BoulderStoreState({
    this.entities = const <int, BoulderModel>{},
    this.feeds = const <String, BoulderFeedState>{},
  });

  final Map<int, BoulderModel> entities;
  final Map<String, BoulderFeedState> feeds;

  BoulderStoreState copyWith({
    Map<int, BoulderModel>? entities,
    Map<String, BoulderFeedState>? feeds,
  }) {
    return BoulderStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
    );
  }
}

const _sentinel = Object();

class BoulderFeedState {
  const BoulderFeedState({
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

  BoulderFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    Object? nextSubCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return BoulderFeedState(
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

class BoulderFeedViewData {
  const BoulderFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<BoulderModel> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final fetchBouldersUseCaseProvider = Provider<FetchBouldersUseCase>(
  (ref) => di<FetchBouldersUseCase>(),
);

final fetchRecBouldersUseCaseProvider = Provider<FetchRecBouldersUseCase>(
  (ref) => di<FetchRecBouldersUseCase>(),
);

final boulderStoreProvider =
    StateNotifierProvider<BoulderStore, BoulderStoreState>((ref) {
      final fetchBoulders = ref.watch(fetchBouldersUseCaseProvider);
      final fetchRecBoulders = ref.watch(fetchRecBouldersUseCaseProvider);
      return BoulderStore(fetchBoulders, fetchRecBoulders);
    });

final boulderFeedProvider =
    Provider.family<BoulderFeedViewData, BoulderSortOption>((ref, sort) {
      final state = ref.watch(boulderStoreProvider);
      final key = 'standard_${sort.name}';
      final feed = state.feeds[key] ?? const BoulderFeedState();
      final items = feed.ids
          .map((id) => state.entities[id])
          .whereType<BoulderModel>()
          .toList();
      final isInitialLoading = feed.isLoading && items.isEmpty;
      return BoulderFeedViewData(
        items: items,
        isLoading: feed.isLoading,
        isInitialLoading: isInitialLoading,
        isLoadingMore: feed.isLoadingMore,
        hasNext: feed.hasNext,
        errorMessage: feed.errorMessage,
      );
    });

final recommendedBoulderFeedProvider = Provider<BoulderFeedViewData>((ref) {
  final state = ref.watch(boulderStoreProvider);
  final feed = state.feeds['recommended'] ?? const BoulderFeedState();
  final items = feed.ids
      .map((id) => state.entities[id])
      .whereType<BoulderModel>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return BoulderFeedViewData(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});
