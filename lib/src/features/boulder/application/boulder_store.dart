import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/approach_service.dart';
import 'package:boulderside_flutter/src/features/boulder/data/services/weather_service.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/approach_model.dart';
import 'package:boulderside_flutter/src/features/boulder/domain/models/daily_weather_info.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/rec_boulder_page.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_rec_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:boulderside_flutter/src/features/route/application/route_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BoulderStore extends StateNotifier<BoulderStoreState> {
  BoulderStore(
    this._fetchBoulders,
    this._fetchRecBoulders,
    this._detailService,
    this._weatherService,
    this._approachService,
    this._routeService,
    this._ref,
  ) : super(const BoulderStoreState());

  final FetchBouldersUseCase _fetchBoulders;
  final FetchRecBouldersUseCase _fetchRecBoulders;
  final BoulderDetailService _detailService;
  final WeatherService _weatherService;
  final ApproachService _approachService;
  final RouteService _routeService;
  final Ref _ref;

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

  BoulderDetailState _detailState(int boulderId) {
    return state.details[boulderId] ?? const BoulderDetailState();
  }

  void _setDetailState(int boulderId, BoulderDetailState detailState) {
    final updated = Map<int, BoulderDetailState>.from(state.details)
      ..[boulderId] = detailState;
    state = state.copyWith(details: updated);
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

  Future<void> loadBoulderDetail(int boulderId, {bool force = false}) async {
    if (boulderId == 0) return;
    final current = _detailState(boulderId);
    if (!force && current.detail != null) return;

    _setDetailState(
      boulderId,
      current.copyWith(isDetailLoading: true, detailError: null),
    );
    try {
      final detail = await _detailService.fetchDetail(boulderId);
      _upsertBoulders([detail]);
      _setDetailState(
        boulderId,
        _detailState(
          boulderId,
        ).copyWith(detail: detail, isDetailLoading: false, detailError: null),
      );
    } catch (error) {
      _setDetailState(
        boulderId,
        _detailState(
          boulderId,
        ).copyWith(isDetailLoading: false, detailError: '바위 정보를 불러오지 못했습니다.'),
      );
    }
  }

  Future<void> loadWeather(int boulderId, {bool force = false}) async {
    if (boulderId == 0) return;
    final current = _detailState(boulderId);
    if (!force && current.weather.isNotEmpty) return;

    _setDetailState(
      boulderId,
      current.copyWith(isWeatherLoading: true, weatherError: null),
    );
    try {
      final weather = await _weatherService.fetchWeather(boulderId: boulderId);
      _setDetailState(
        boulderId,
        _detailState(boulderId).copyWith(
          weather: weather,
          isWeatherLoading: false,
          weatherError: null,
        ),
      );
    } catch (error) {
      _setDetailState(
        boulderId,
        _detailState(
          boulderId,
        ).copyWith(isWeatherLoading: false, weatherError: '날씨 정보를 불러오지 못했습니다.'),
      );
    }
  }

  Future<void> loadApproaches(int boulderId, {bool force = false}) async {
    if (boulderId == 0) return;
    final current = _detailState(boulderId);
    if (!force && current.approaches.isNotEmpty) return;

    _setDetailState(
      boulderId,
      current.copyWith(isApproachLoading: true, approachError: null),
    );
    try {
      final approaches = await _approachService.fetchApproaches(boulderId);
      approaches.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      _setDetailState(
        boulderId,
        _detailState(boulderId).copyWith(
          approaches: approaches,
          isApproachLoading: false,
          approachError: null,
        ),
      );
    } catch (error) {
      _setDetailState(
        boulderId,
        _detailState(boulderId).copyWith(
          isApproachLoading: false,
          approachError: '어프로치 정보를 불러오지 못했습니다.',
        ),
      );
    }
  }

  Future<void> loadRoutes(int boulderId, {bool force = false}) async {
    if (boulderId == 0) return;
    final current = _detailState(boulderId);
    if (!force && current.routes.isNotEmpty) return;
    _setDetailState(
      boulderId,
      current.copyWith(isRoutesLoading: true, routesError: null),
    );
    try {
      final routes = await _routeService.fetchRoutesByBoulder(boulderId);
      final routeStore = _ref.read(routeStoreProvider.notifier);
      for (final route in routes) {
        routeStore.upsertRoute(route);
      }
      _setDetailState(
        boulderId,
        _detailState(boulderId).copyWith(
          routes: routes,
          isRoutesLoading: false,
          routesError: null,
        ),
      );
    } catch (error) {
      _setDetailState(
        boulderId,
        _detailState(boulderId).copyWith(
          isRoutesLoading: false,
          routesError: '루트 정보를 불러오지 못했습니다.',
        ),
      );
    }
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
    this.details = const <int, BoulderDetailState>{},
  });

  final Map<int, BoulderModel> entities;
  final Map<String, BoulderFeedState> feeds;
  final Map<int, BoulderDetailState> details;

  BoulderStoreState copyWith({
    Map<int, BoulderModel>? entities,
    Map<String, BoulderFeedState>? feeds,
    Map<int, BoulderDetailState>? details,
  }) {
    return BoulderStoreState(
      entities: entities ?? this.entities,
      feeds: feeds ?? this.feeds,
      details: details ?? this.details,
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

final boulderDetailServiceProvider = Provider<BoulderDetailService>(
  (ref) => di<BoulderDetailService>(),
);

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => di<WeatherService>(),
);

final approachServiceProvider = Provider<ApproachService>(
  (ref) => di<ApproachService>(),
);

final routeServiceProvider = Provider<RouteService>(
  (ref) => di<RouteService>(),
);

final boulderStoreProvider =
    StateNotifierProvider<BoulderStore, BoulderStoreState>((ref) {
      final fetchBoulders = ref.watch(fetchBouldersUseCaseProvider);
      final fetchRecBoulders = ref.watch(fetchRecBouldersUseCaseProvider);
      final detailService = ref.watch(boulderDetailServiceProvider);
      final weatherService = ref.watch(weatherServiceProvider);
      final approachService = ref.watch(approachServiceProvider);
      final routeService = ref.watch(routeServiceProvider);
      return BoulderStore(
        fetchBoulders,
        fetchRecBoulders,
        detailService,
        weatherService,
        approachService,
        routeService,
        ref,
      );
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

class BoulderDetailState {
  const BoulderDetailState({
    this.detail,
    this.isDetailLoading = false,
    this.detailError,
    this.weather = const <DailyWeatherInfo>[],
    this.isWeatherLoading = false,
    this.weatherError,
    this.approaches = const <ApproachModel>[],
    this.isApproachLoading = false,
    this.approachError,
    this.routes = const <RouteModel>[],
    this.isRoutesLoading = false,
    this.routesError,
  });

  final BoulderModel? detail;
  final bool isDetailLoading;
  final String? detailError;
  final List<DailyWeatherInfo> weather;
  final bool isWeatherLoading;
  final String? weatherError;
  final List<ApproachModel> approaches;
  final bool isApproachLoading;
  final String? approachError;
  final List<RouteModel> routes;
  final bool isRoutesLoading;
  final String? routesError;

  BoulderDetailState copyWith({
    BoulderModel? detail,
    bool? isDetailLoading,
    Object? detailError = _sentinel,
    List<DailyWeatherInfo>? weather,
    bool? isWeatherLoading,
    Object? weatherError = _sentinel,
    List<ApproachModel>? approaches,
    bool? isApproachLoading,
    Object? approachError = _sentinel,
    List<RouteModel>? routes,
    bool? isRoutesLoading,
    Object? routesError = _sentinel,
  }) {
    return BoulderDetailState(
      detail: detail ?? this.detail,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      detailError: identical(detailError, _sentinel)
          ? this.detailError
          : detailError as String?,
      weather: weather ?? this.weather,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
      weatherError: identical(weatherError, _sentinel)
          ? this.weatherError
          : weatherError as String?,
      approaches: approaches ?? this.approaches,
      isApproachLoading: isApproachLoading ?? this.isApproachLoading,
      approachError: identical(approachError, _sentinel)
          ? this.approachError
          : approachError as String?,
      routes: routes ?? this.routes,
      isRoutesLoading: isRoutesLoading ?? this.isRoutesLoading,
      routesError: identical(routesError, _sentinel)
          ? this.routesError
          : routesError as String?,
    );
  }
}

class BoulderDetailViewData {
  const BoulderDetailViewData({
    required this.detail,
    required this.isDetailLoading,
    required this.detailError,
    required this.weather,
    required this.isWeatherLoading,
    required this.weatherError,
    required this.approaches,
    required this.isApproachLoading,
    required this.approachError,
    required this.routes,
    required this.isRoutesLoading,
    required this.routesError,
  });

  final BoulderModel? detail;
  final bool isDetailLoading;
  final String? detailError;
  final List<DailyWeatherInfo> weather;
  final bool isWeatherLoading;
  final String? weatherError;
  final List<ApproachModel> approaches;
  final bool isApproachLoading;
  final String? approachError;
  final List<RouteModel> routes;
  final bool isRoutesLoading;
  final String? routesError;
}

final boulderDetailProvider = Provider.family<BoulderDetailViewData, int>((
  ref,
  boulderId,
) {
  final state = ref.watch(boulderStoreProvider);
  final detailState = state.details[boulderId] ?? const BoulderDetailState();
  return BoulderDetailViewData(
    detail: detailState.detail,
    isDetailLoading: detailState.isDetailLoading,
    detailError: detailState.detailError,
    weather: detailState.weather,
    isWeatherLoading: detailState.isWeatherLoading,
    weatherError: detailState.weatherError,
    approaches: detailState.approaches,
    isApproachLoading: detailState.isApproachLoading,
    approachError: detailState.approachError,
    routes: detailState.routes,
    isRoutesLoading: detailState.isRoutesLoading,
    routesError: detailState.routesError,
  );
});

final boulderEntityProvider = Provider.family<BoulderModel?, int>((
  ref,
  boulderId,
) {
  final state = ref.watch(boulderStoreProvider);
  return state.entities[boulderId];
});
