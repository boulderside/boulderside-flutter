import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_boulder_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/liked_route_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_routes_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyLikesStore extends StateNotifier<MyLikesState> {
  MyLikesStore(
    this._fetchLikedRoutes,
    this._fetchLikedBoulders,
    this._toggleRouteLike,
    this._toggleBoulderLike,
  ) : super(const MyLikesState());

  final FetchLikedRoutesUseCase _fetchLikedRoutes;
  final FetchLikedBouldersUseCase _fetchLikedBoulders;
  final ToggleRouteLikeUseCase _toggleRouteLike;
  final ToggleBoulderLikeUseCase _toggleBoulderLike;

  static const int _pageSize = 10;

  Future<void> loadInitialRoutes() async {
    final feed = state.routeFeed;
    if (feed.isLoading) return;
    _setRouteFeed(feed.copyWith(isLoading: true, errorMessage: null));
    final Result<LikedRoutePage> result = await _fetchLikedRoutes(
      cursor: null,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsertRoutes(page.items, reset: true);
        _setRouteFeed(
          feed.copyWith(
            ids: page.items.map((route) => route.id).toList(),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setRouteFeed(
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> loadInitialBoulders() async {
    final feed = state.boulderFeed;
    if (feed.isLoading) return;
    _setBoulderFeed(feed.copyWith(isLoading: true, errorMessage: null));
    final Result<LikedBoulderPage> result = await _fetchLikedBoulders(
      cursor: null,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsertBoulders(page.items, reset: true);
        _setBoulderFeed(
          feed.copyWith(
            ids: page.items.map((boulder) => boulder.id).toList(),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setBoulderFeed(
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> refreshRoutes() => loadInitialRoutes();

  Future<void> refreshBoulders() => loadInitialBoulders();

  Future<void> loadMoreRoutes() async {
    final feed = state.routeFeed;
    if (!feed.hasNext || feed.isLoading || feed.isLoadingMore) return;
    _setRouteFeed(feed.copyWith(isLoadingMore: true, errorMessage: null));
    final Result<LikedRoutePage> result = await _fetchLikedRoutes(
      cursor: feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsertRoutes(page.items);
        _setRouteFeed(
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setRouteFeed(
          feed.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
    );
  }

  Future<void> loadMoreBoulders() async {
    final feed = state.boulderFeed;
    if (!feed.hasNext || feed.isLoading || feed.isLoadingMore) return;
    _setBoulderFeed(feed.copyWith(isLoadingMore: true, errorMessage: null));
    final Result<LikedBoulderPage> result = await _fetchLikedBoulders(
      cursor: feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsertBoulders(page.items);
        _setBoulderFeed(
          feed.copyWith(
            ids: _mergeIds(feed.ids, page.items),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        _setBoulderFeed(
          feed.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
    );
  }

  Future<void> toggleRouteLike(int routeId) async {
    final existed = state.routeEntities.containsKey(routeId);
    if (existed) {
      _removeRoute(routeId);
    }
    try {
      await _toggleRouteLike(routeId);
    } catch (_) {
      await loadInitialRoutes();
    }
  }

  Future<void> toggleBoulderLike(int boulderId) async {
    final existed = state.boulderEntities.containsKey(boulderId);
    if (existed) {
      _removeBoulder(boulderId);
    }
    try {
      await _toggleBoulderLike(boulderId);
    } catch (_) {
      await loadInitialBoulders();
    }
  }

  void _upsertRoutes(List<RouteModel> routes, {bool reset = false}) {
    if (routes.isEmpty) return;
    final entities = reset
        ? <int, RouteModel>{}
        : Map<int, RouteModel>.from(state.routeEntities);
    for (final route in routes) {
      entities[route.id] = route;
    }
    state = state.copyWith(routeEntities: entities);
  }

  void _upsertBoulders(List<BoulderModel> boulders, {bool reset = false}) {
    if (boulders.isEmpty) return;
    final entities = reset
        ? <int, BoulderModel>{}
        : Map<int, BoulderModel>.from(state.boulderEntities);
    for (final boulder in boulders) {
      entities[boulder.id] = boulder;
    }
    state = state.copyWith(boulderEntities: entities);
  }

  void _removeRoute(int routeId) {
    final entities = Map<int, RouteModel>.from(state.routeEntities)
      ..remove(routeId);
    final feed = state.routeFeed.removeId(routeId);
    state = state.copyWith(routeEntities: entities, routeFeed: feed);
  }

  void _removeBoulder(int boulderId) {
    final entities = Map<int, BoulderModel>.from(state.boulderEntities)
      ..remove(boulderId);
    final feed = state.boulderFeed.removeId(boulderId);
    state = state.copyWith(boulderEntities: entities, boulderFeed: feed);
  }

  void _setRouteFeed(LikedFeedState feed) {
    state = state.copyWith(routeFeed: feed);
  }

  void _setBoulderFeed(LikedFeedState feed) {
    state = state.copyWith(boulderFeed: feed);
  }

  List<int> _mergeIds(List<int> existing, List<dynamic> items) {
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final item in items) {
      final id = item.id as int;
      if (seen.add(id)) {
        ids.add(id);
      }
    }
    return ids;
  }
}

class MyLikesState {
  const MyLikesState({
    this.routeEntities = const <int, RouteModel>{},
    this.boulderEntities = const <int, BoulderModel>{},
    this.routeFeed = const LikedFeedState(),
    this.boulderFeed = const LikedFeedState(),
  });

  final Map<int, RouteModel> routeEntities;
  final Map<int, BoulderModel> boulderEntities;
  final LikedFeedState routeFeed;
  final LikedFeedState boulderFeed;

  MyLikesState copyWith({
    Map<int, RouteModel>? routeEntities,
    Map<int, BoulderModel>? boulderEntities,
    LikedFeedState? routeFeed,
    LikedFeedState? boulderFeed,
  }) {
    return MyLikesState(
      routeEntities: routeEntities ?? this.routeEntities,
      boulderEntities: boulderEntities ?? this.boulderEntities,
      routeFeed: routeFeed ?? this.routeFeed,
      boulderFeed: boulderFeed ?? this.boulderFeed,
    );
  }
}

const _sentinel = Object();

class LikedFeedState {
  const LikedFeedState({
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

  LikedFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return LikedFeedState(
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

  LikedFeedState removeId(int id) {
    final ids = this.ids.where((existing) => existing != id).toList();
    return copyWith(ids: ids);
  }
}

class LikedFeedViewData<T> {
  const LikedFeedViewData({
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

final fetchLikedRoutesUseCaseProvider = Provider<FetchLikedRoutesUseCase>(
  (ref) => di<FetchLikedRoutesUseCase>(),
);

final fetchLikedBouldersUseCaseProvider = Provider<FetchLikedBouldersUseCase>(
  (ref) => di<FetchLikedBouldersUseCase>(),
);

final toggleRouteLikeUseCaseProvider = Provider<ToggleRouteLikeUseCase>(
  (ref) => di<ToggleRouteLikeUseCase>(),
);

final toggleBoulderLikeUseCaseProvider = Provider<ToggleBoulderLikeUseCase>(
  (ref) => di<ToggleBoulderLikeUseCase>(),
);

final myLikesStoreProvider = StateNotifierProvider<MyLikesStore, MyLikesState>((
  ref,
) {
  final fetchRoutes = ref.watch(fetchLikedRoutesUseCaseProvider);
  final fetchBoulders = ref.watch(fetchLikedBouldersUseCaseProvider);
  final toggleRoute = ref.watch(toggleRouteLikeUseCaseProvider);
  final toggleBoulder = ref.watch(toggleBoulderLikeUseCaseProvider);
  return MyLikesStore(fetchRoutes, fetchBoulders, toggleRoute, toggleBoulder);
});

final likedRouteFeedProvider = Provider<LikedFeedViewData<RouteModel>>((ref) {
  final state = ref.watch(myLikesStoreProvider);
  final feed = state.routeFeed;
  final items = feed.ids
      .map((id) => state.routeEntities[id])
      .whereType<RouteModel>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return LikedFeedViewData<RouteModel>(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});

final likedBoulderFeedProvider = Provider<LikedFeedViewData<BoulderModel>>((
  ref,
) {
  final state = ref.watch(myLikesStoreProvider);
  final feed = state.boulderFeed;
  final items = feed.ids
      .map((id) => state.boulderEntities[id])
      .whereType<BoulderModel>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return LikedFeedViewData<BoulderModel>(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});
