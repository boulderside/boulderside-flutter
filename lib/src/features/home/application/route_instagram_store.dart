import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_instagrams_by_route_id_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteInstagramStore extends StateNotifier<RouteInstagramState> {
  RouteInstagramStore(this._fetchUseCase, this.routeId)
    : super(const RouteInstagramState());

  final FetchInstagramsByRouteIdUseCase _fetchUseCase;
  final int routeId;
  static const int _pageSize = 10;

  Future<void> loadInitial() async {
    state = state.copyWith(
      feed: state.feed.copyWith(isLoading: true, errorMessage: null),
    );
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (state.feed.isLoading ||
        state.feed.isLoadingMore ||
        !state.feed.hasNext) {
      return;
    }
    state = state.copyWith(
      feed: state.feed.copyWith(isLoadingMore: true, errorMessage: null),
    );
    await _load(reset: false);
  }

  Future<void> refresh() => loadInitial();

  void applyLikeResult(LikeToggleResult result) {
    if (!result.isInstagram || result.instagramId == null) return;
    final targetId = result.instagramId;
    final entities = Map<int, RouteInstagram>.from(state.entities);
    var updated = false;
    for (final entry in entities.entries) {
      final current = entry.value;
      if (current.instagram.id != targetId) continue;
      entities[entry.key] = RouteInstagram(
        routeInstagramId: current.routeInstagramId,
        routeId: current.routeId,
        instagramId: current.instagramId,
        instagram: current.instagram.copyWith(
          liked: result.liked ?? current.instagram.liked,
          likeCount: result.likeCount ?? current.instagram.likeCount,
        ),
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
      updated = true;
    }
    if (updated) {
      state = state.copyWith(entities: entities);
    }
  }

  Future<void> _load({required bool reset}) async {
    final result = await _fetchUseCase(
      routeId: routeId,
      cursor: reset ? null : state.feed.nextCursor,
      size: _pageSize,
    );
    result.when(
      success: (page) {
        _upsert(page.items, reset: reset);
        state = state.copyWith(
          feed: state.feed.copyWith(
            ids: _mergeIds(state.feed.ids, page.items, reset: reset),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext,
            isLoading: false,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          feed: state.feed.copyWith(
            isLoading: false,
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }

  void _upsert(List<RouteInstagram> items, {required bool reset}) {
    if (items.isEmpty) return;
    final entities = reset
        ? <int, RouteInstagram>{}
        : Map<int, RouteInstagram>.from(state.entities);
    for (final item in items) {
      entities[item.routeInstagramId] = item;
    }
    state = state.copyWith(entities: entities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<RouteInstagram> next, {
    required bool reset,
  }) {
    if (reset) {
      return next.map((item) => item.routeInstagramId).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final item in next) {
      if (seen.add(item.routeInstagramId)) {
        ids.add(item.routeInstagramId);
      }
    }
    return ids;
  }
}

class RouteInstagramState {
  const RouteInstagramState({
    this.entities = const <int, RouteInstagram>{},
    this.feed = const RouteInstagramFeedState(),
  });

  final Map<int, RouteInstagram> entities;
  final RouteInstagramFeedState feed;

  RouteInstagramState copyWith({
    Map<int, RouteInstagram>? entities,
    RouteInstagramFeedState? feed,
  }) {
    return RouteInstagramState(
      entities: entities ?? this.entities,
      feed: feed ?? this.feed,
    );
  }
}

const _sentinel = Object();

class RouteInstagramFeedState {
  const RouteInstagramFeedState({
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

  RouteInstagramFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return RouteInstagramFeedState(
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

class RouteInstagramFeedViewData {
  const RouteInstagramFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<RouteInstagram> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final fetchInstagramsByRouteIdUseCaseProvider =
    Provider<FetchInstagramsByRouteIdUseCase>(
      (ref) => di<FetchInstagramsByRouteIdUseCase>(),
    );

final routeInstagramStoreProvider =
    StateNotifierProvider.family<RouteInstagramStore, RouteInstagramState, int>(
      (ref, routeId) {
        return RouteInstagramStore(
          ref.watch(fetchInstagramsByRouteIdUseCaseProvider),
          routeId,
        );
      },
    );

final routeInstagramFeedProvider =
    Provider.family<RouteInstagramFeedViewData, int>((ref, routeId) {
      final state = ref.watch(routeInstagramStoreProvider(routeId));
      final feed = state.feed;
      final items = feed.ids
          .map((id) => state.entities[id])
          .whereType<RouteInstagram>()
          .toList();
      final isInitialLoading = feed.isLoading && items.isEmpty;
      return RouteInstagramFeedViewData(
        items: items,
        isLoading: feed.isLoading,
        isInitialLoading: isInitialLoading,
        isLoadingMore: feed.isLoadingMore,
        hasNext: feed.hasNext,
        errorMessage: feed.errorMessage,
      );
    });
