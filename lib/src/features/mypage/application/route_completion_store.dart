import 'dart:async';

import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/create_route_completion_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/delete_route_completion_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_route_completions_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/update_route_completion_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteCompletionStore extends StateNotifier<RouteCompletionState> {
  RouteCompletionStore(
    this._fetchRouteCompletions,
    this._createRouteCompletion,
    this._updateRouteCompletion,
    this._deleteRouteCompletion,
    this._routeIndexCache,
  ) : super(const RouteCompletionState());

  final FetchRouteCompletionsUseCase _fetchRouteCompletions;
  final CreateRouteCompletionUseCase _createRouteCompletion;
  final UpdateRouteCompletionUseCase _updateRouteCompletion;
  final DeleteRouteCompletionUseCase _deleteRouteCompletion;
  final RouteIndexCache _routeIndexCache;

  Future<void> loadCompletions() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    final Result<List<RouteCompletionModel>> result =
        await _fetchRouteCompletions();
    result.when(
      success: (items) {
        state = state.copyWith(
          completions: items.map(_attachRoute).toList(),
          isLoading: false,
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          completions: const <RouteCompletionModel>[],
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
    if (state.routeIndexMap.isEmpty && !state.isRouteIndexLoading) {
      unawaited(ensureRouteIndexLoaded());
    }
  }

  Future<void> refresh() => loadCompletions();

  Future<void> ensureRouteIndexLoaded() async {
    if (state.routeIndexMap.isNotEmpty || state.isRouteIndexLoading) {
      return;
    }
    state = state.copyWith(isRouteIndexLoading: true, routeIndexError: null);
    try {
      final routes = await _routeIndexCache.load();
      final map = {for (final route in routes) route.id: route};
      state = state.copyWith(
        routeIndexList: routes,
        routeIndexMap: map,
        isRouteIndexLoading: false,
        routeIndexError: null,
      );
      _syncCompletions();
    } catch (error) {
      state = state.copyWith(
        isRouteIndexLoading: false,
        routeIndexError: '루트 목록을 불러오지 못했습니다.',
      );
    }
  }

  Future<void> addCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    await _mutate(() async {
      final Result<RouteCompletionModel> result = await _createRouteCompletion(
        routeId: routeId,
        completed: completed,
        memo: memo,
      );
      result.when(
        success: (completion) {
          final enriched = _attachRoute(completion);
          final completions = <RouteCompletionModel>[
            enriched,
            ...state.completions.where(
              (item) => item.routeId != enriched.routeId,
            ),
          ];
          state = state.copyWith(completions: completions, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  Future<void> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    await _mutate(() async {
      final Result<RouteCompletionModel> result = await _updateRouteCompletion(
        routeId: routeId,
        completed: completed,
        memo: memo,
      );
      result.when(
        success: (completion) {
          final enriched = _attachRoute(completion);
          final completions = List<RouteCompletionModel>.from(
            state.completions,
          );
          final index = completions.indexWhere(
            (item) => item.routeId == enriched.routeId,
          );
          if (index >= 0) {
            completions[index] = enriched;
          } else {
            completions.insert(0, enriched);
          }
          state = state.copyWith(completions: completions, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  Future<void> deleteCompletion(int routeId) async {
    await _mutate(() async {
      final Result<void> result = await _deleteRouteCompletion(routeId);
      result.when(
        success: (_) {
          final completions = state.completions
              .where((item) => item.routeId != routeId)
              .toList();
          state = state.copyWith(completions: completions, errorMessage: null);
        },
        failure: _handleFailure,
      );
    });
  }

  RouteModel? routeById(int routeId) => state.routeIndexMap[routeId];

  Future<void> _mutate(Future<void> Function() action) async {
    state = state.copyWith(isMutating: true);
    try {
      await action();
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  RouteCompletionModel _attachRoute(RouteCompletionModel completion) {
    final route = state.routeIndexMap[completion.routeId];
    if (route == null || completion.route == route) {
      return completion;
    }
    return completion.copyWith(route: route);
  }

  void _syncCompletions() {
    if (state.routeIndexMap.isEmpty) return;
    final updated = state.completions.map(_attachRoute).toList();
    state = state.copyWith(completions: updated);
  }

  Never _handleFailure(AppFailure failure) {
    state = state.copyWith(errorMessage: failure.message);
    throw failure;
  }
}

class RouteCompletionState {
  const RouteCompletionState({
    this.completions = const <RouteCompletionModel>[],
    this.isLoading = false,
    this.isMutating = false,
    this.errorMessage,
    this.routeIndexList = const <RouteModel>[],
    this.routeIndexMap = const <int, RouteModel>{},
    this.isRouteIndexLoading = false,
    this.routeIndexError,
  });

  final List<RouteCompletionModel> completions;
  final bool isLoading;
  final bool isMutating;
  final String? errorMessage;
  final List<RouteModel> routeIndexList;
  final Map<int, RouteModel> routeIndexMap;
  final bool isRouteIndexLoading;
  final String? routeIndexError;

  List<RouteModel> get availableRoutes => routeIndexList;

  RouteCompletionState copyWith({
    List<RouteCompletionModel>? completions,
    bool? isLoading,
    bool? isMutating,
    String? errorMessage,
    List<RouteModel>? routeIndexList,
    Map<int, RouteModel>? routeIndexMap,
    bool? isRouteIndexLoading,
    String? routeIndexError,
  }) {
    return RouteCompletionState(
      completions: completions ?? this.completions,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      errorMessage: errorMessage ?? this.errorMessage,
      routeIndexList: routeIndexList ?? this.routeIndexList,
      routeIndexMap: routeIndexMap ?? this.routeIndexMap,
      isRouteIndexLoading: isRouteIndexLoading ?? this.isRouteIndexLoading,
      routeIndexError: routeIndexError ?? this.routeIndexError,
    );
  }
}

final fetchRouteCompletionsUseCaseProvider =
    Provider<FetchRouteCompletionsUseCase>(
      (ref) => di<FetchRouteCompletionsUseCase>(),
    );

final createRouteCompletionUseCaseProvider =
    Provider<CreateRouteCompletionUseCase>(
      (ref) => di<CreateRouteCompletionUseCase>(),
    );

final updateRouteCompletionUseCaseProvider =
    Provider<UpdateRouteCompletionUseCase>(
      (ref) => di<UpdateRouteCompletionUseCase>(),
    );

final deleteRouteCompletionUseCaseProvider =
    Provider<DeleteRouteCompletionUseCase>(
      (ref) => di<DeleteRouteCompletionUseCase>(),
    );

final routeIndexCacheProvider = Provider<RouteIndexCache>(
  (ref) => di<RouteIndexCache>(),
);

final routeCompletionStoreProvider =
    StateNotifierProvider<RouteCompletionStore, RouteCompletionState>((ref) {
      return RouteCompletionStore(
        ref.watch(fetchRouteCompletionsUseCaseProvider),
        ref.watch(createRouteCompletionUseCaseProvider),
        ref.watch(updateRouteCompletionUseCaseProvider),
        ref.watch(deleteRouteCompletionUseCaseProvider),
        ref.watch(routeIndexCacheProvider),
      );
    });
