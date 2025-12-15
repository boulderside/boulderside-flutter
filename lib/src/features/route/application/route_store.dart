import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/route_detail_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_routes.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_routes_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_sort_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteStore extends StateNotifier<RouteStoreState> {
  RouteStore(this._fetchRoutes, this._routeDetailService, this._boulderService)
    : super(const RouteStoreState());

  final FetchRoutesUseCase _fetchRoutes;
  final RouteDetailService _routeDetailService;
  final BoulderService _boulderService;
  final Map<int, Future<RouteDetailModel>> _pendingDetails =
      <int, Future<RouteDetailModel>>{};
  static const int _pageSize = 5;

  String _key(RouteSortOption sort) => 'route_${sort.name}';

  RouteFeedState _feed(RouteSortOption sort) {
    final key = _key(sort);
    return state.feeds[key] ?? const RouteFeedState();
  }

  void _setFeed(RouteSortOption sort, RouteFeedState feed) {
    final key = _key(sort);
    final updatedFeeds = Map<String, RouteFeedState>.from(state.feeds)
      ..[key] = feed;
    state = state.copyWith(feeds: updatedFeeds);
  }

  RouteDetailState _detailState(int routeId) {
    return state.details[routeId] ?? const RouteDetailState();
  }

  void _setDetailState(int routeId, RouteDetailState detailState) {
    final updatedDetails = Map<int, RouteDetailState>.from(state.details)
      ..[routeId] = detailState;
    state = state.copyWith(details: updatedDetails);
  }

  void _upsertRoutes(List<RouteModel> routes) {
    if (routes.isEmpty) return;
    final updatedEntities = Map<int, RouteModel>.from(state.entities);
    for (final route in routes) {
      updatedEntities[route.id] = route;
    }
    state = state.copyWith(entities: updatedEntities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<RouteModel> next, {
    bool reset = false,
  }) {
    if (reset) {
      return next.map((route) => route.id).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final route in next) {
      if (seen.add(route.id)) {
        ids.add(route.id);
      }
    }
    return ids;
  }

  Future<void> loadInitial(RouteSortOption sort) async {
    final feed = _feed(sort);
    _setFeed(sort, feed.copyWith(isLoading: true, errorMessage: null));

    final Result<PaginatedRoutes> result = await _fetchRoutes(
      sortType: sort.name,
      cursor: null,
      subCursor: null,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertRoutes(page.items);
        _setFeed(
          sort,
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
          sort,
          feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  Future<void> loadMore(RouteSortOption sort) async {
    final feed = _feed(sort);
    if (!feed.hasNext || feed.isLoading || feed.isLoadingMore) return;

    _setFeed(sort, feed.copyWith(isLoadingMore: true, errorMessage: null));

    final Result<PaginatedRoutes> result = await _fetchRoutes(
      sortType: sort.name,
      cursor: feed.nextCursor,
      subCursor: feed.nextSubCursor,
      size: _pageSize,
    );

    result.when(
      success: (page) {
        _upsertRoutes(page.items);
        _setFeed(
          sort,
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
          sort,
          feed.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
    );
  }

  void applyLikeResult(LikeToggleResult result) {
    final routeId = result.routeId ?? result.targetId;
    if (routeId == null) return;
    final current = state.entities[routeId];
    if (current == null) return;
    final updated = current.copyWith(
      liked: result.liked ?? current.liked,
      likeCount: result.likeCount ?? current.likeCount,
    );
    _upsertRoutes([updated]);
  }

  void upsertRoute(RouteModel route) {
    _upsertRoutes([route]);
  }

  void updateCommentCount(int id, int count) {
    final entities = Map<int, RouteModel>.from(state.entities);
    if (entities.containsKey(id)) {
      entities[id] = entities[id]!.copyWith(commentCount: count);
    }

    final details = Map<int, RouteDetailState>.from(state.details);
    if (details.containsKey(id)) {
      final detailState = details[id]!;
      if (detailState.detail != null) {
        final currentDetail = detailState.detail!;
        details[id] = detailState.copyWith(
          detail: currentDetail.copyWith(
            route: currentDetail.route.copyWith(commentCount: count),
          ),
        );
      }
    }

    state = state.copyWith(entities: entities, details: details);
  }

  RouteDetailModel? getCachedDetail(int routeId) {
    return state.details[routeId]?.detail;
  }

  Future<RouteDetailModel> fetchDetail(
    int routeId, {
    bool force = false,
  }) async {
    final current = _detailState(routeId);
    if (!force && current.detail != null) {
      return current.detail!;
    }

    if (!force) {
      final pending = _pendingDetails[routeId];
      if (pending != null) {
        return pending;
      }
    }

    _setDetailState(
      routeId,
      current.copyWith(isLoading: true, errorMessage: null),
    );

    final Future<RouteDetailModel> request = _routeDetailService.fetchDetail(
      routeId,
    );
    final Future<BoulderModel?> boulderRequest = _boulderService
        .fetchBoulderByRouteId(routeId);
    _pendingDetails[routeId] = request;

    try {
      final detail = await request;
      BoulderModel? connectedBoulder;
      try {
        connectedBoulder = await boulderRequest;
      } catch (_) {
        connectedBoulder = null;
      }
      final resolvedDetail = connectedBoulder != null
          ? detail.copyWith(
              connectedBoulder: connectedBoulder,
              boulderName: connectedBoulder.name,
            )
          : detail;
      _pendingDetails.remove(routeId);
      _upsertRoutes([resolvedDetail.route]);
      _setDetailState(
        routeId,
        RouteDetailState(
          detail: resolvedDetail,
          isLoading: false,
          errorMessage: null,
        ),
      );
      return resolvedDetail;
    } catch (error) {
      _pendingDetails.remove(routeId);
      _setDetailState(
        routeId,
        current.copyWith(isLoading: false, errorMessage: error.toString()),
      );
      rethrow;
    }
  }
}

class RouteStoreState {
  const RouteStoreState({
    this.entities = const <int, RouteModel>{},
    this.feeds = const <String, RouteFeedState>{},
    this.details = const <int, RouteDetailState>{},
  });

  final Map<int, RouteModel> entities;
  final Map<String, RouteFeedState> feeds;
  final Map<int, RouteDetailState> details;

  RouteStoreState copyWith({
    Map<int, RouteModel>? entities,
    Map<String, RouteFeedState>? feeds,
    Map<int, RouteDetailState>? details,
  }) {
    return RouteStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
      details: details ?? this.details,
    );
  }
}

const _sentinel = Object();

class RouteFeedState {
  const RouteFeedState({
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

  RouteFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    Object? nextSubCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return RouteFeedState(
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

class RouteDetailState {
  const RouteDetailState({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
  });

  final RouteDetailModel? detail;
  final bool isLoading;
  final String? errorMessage;

  RouteDetailState copyWith({
    RouteDetailModel? detail,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return RouteDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class RouteFeedViewData {
  const RouteFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<RouteModel> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final fetchRoutesUseCaseProvider = Provider<FetchRoutesUseCase>(
  (ref) => di<FetchRoutesUseCase>(),
);

final routeDetailServiceProvider = Provider<RouteDetailService>(
  (ref) => di<RouteDetailService>(),
);

final boulderServiceProvider = Provider<BoulderService>(
  (ref) => di<BoulderService>(),
);

final routeStoreProvider = StateNotifierProvider<RouteStore, RouteStoreState>((
  ref,
) {
  final fetchRoutes = ref.watch(fetchRoutesUseCaseProvider);
  final detailService = ref.watch(routeDetailServiceProvider);
  final boulderService = ref.watch(boulderServiceProvider);
  return RouteStore(fetchRoutes, detailService, boulderService);
});

final routeFeedProvider = Provider.family<RouteFeedViewData, RouteSortOption>((
  ref,
  sort,
) {
  final state = ref.watch(routeStoreProvider);
  final key = 'route_${sort.name}';
  final feed = state.feeds[key] ?? const RouteFeedState();
  final items = feed.ids
      .map((id) => state.entities[id])
      .whereType<RouteModel>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return RouteFeedViewData(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});

class RouteDetailViewData {
  const RouteDetailViewData({
    required this.detail,
    required this.isLoading,
    required this.errorMessage,
  });

  final RouteDetailModel? detail;
  final bool isLoading;
  final String? errorMessage;
}

final routeDetailProvider = Provider.family<RouteDetailViewData, int>((
  ref,
  routeId,
) {
  final state = ref.watch(routeStoreProvider);
  final detailState = state.details[routeId] ?? const RouteDetailState();
  return RouteDetailViewData(
    detail: detailState.detail,
    isLoading: detailState.isLoading,
    errorMessage: detailState.errorMessage,
  );
});

final routeEntityProvider = Provider.family<RouteModel?, int>((ref, routeId) {
  final state = ref.watch(routeStoreProvider);
  return state.entities[routeId];
});
