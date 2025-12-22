import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/delete_instagram_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_my_instagrams_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/update_instagram_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyInstagramsStore extends StateNotifier<MyInstagramsState> {
  MyInstagramsStore(
    this._fetchUseCase,
    this._deleteUseCase,
    this._updateUseCase,
  ) : super(const MyInstagramsState());

  final FetchMyInstagramsUseCase _fetchUseCase;
  final DeleteInstagramUseCase _deleteUseCase;
  final UpdateInstagramUseCase _updateUseCase;
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

  Future<void> deleteInstagram(int id) async {
    final result = await _deleteUseCase(id);
    result.when(
      success: (_) {
        // Remove from entities and feed
        final entities = Map<int, Instagram>.from(state.entities);
        entities.remove(id);
        final ids = state.feed.ids.where((itemId) => itemId != id).toList();
        state = state.copyWith(
          entities: entities,
          feed: state.feed.copyWith(ids: ids),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          feed: state.feed.copyWith(errorMessage: failure.message),
        );
      },
    );
  }

  Future<bool> updateInstagram({
    required int instagramId,
    required String url,
    required List<int> routeIds,
  }) async {
    final result = await _updateUseCase(
      instagramId: instagramId,
      url: url,
      routeIds: routeIds,
    );
    var success = false;
    result.when(
      success: (_) {
        final current = state.entities[instagramId];
        if (current == null) return;
        final entities = Map<int, Instagram>.from(state.entities)
          ..[instagramId] = current.copyWith(url: url, routeIds: routeIds);
        state = state.copyWith(entities: entities);
        success = true;
      },
      failure: (failure) {
        state = state.copyWith(
          feed: state.feed.copyWith(errorMessage: failure.message),
        );
      },
    );
    return success;
  }

  Future<void> _load({required bool reset}) async {
    final result = await _fetchUseCase(
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

  void _upsert(List<Instagram> items, {required bool reset}) {
    if (items.isEmpty) return;
    final entities = reset
        ? <int, Instagram>{}
        : Map<int, Instagram>.from(state.entities);
    for (final item in items) {
      entities[item.id] = item;
    }
    state = state.copyWith(entities: entities);
  }

  List<int> _mergeIds(
    List<int> existing,
    List<Instagram> next, {
    required bool reset,
  }) {
    if (reset) {
      return next.map((item) => item.id).toList();
    }
    final ids = List<int>.from(existing);
    final seen = existing.toSet();
    for (final item in next) {
      if (seen.add(item.id)) {
        ids.add(item.id);
      }
    }
    return ids;
  }
}

class MyInstagramsState {
  const MyInstagramsState({
    this.entities = const <int, Instagram>{},
    this.feed = const MyInstagramsFeedState(),
  });

  final Map<int, Instagram> entities;
  final MyInstagramsFeedState feed;

  MyInstagramsState copyWith({
    Map<int, Instagram>? entities,
    MyInstagramsFeedState? feed,
  }) {
    return MyInstagramsState(
      entities: entities ?? this.entities,
      feed: feed ?? this.feed,
    );
  }
}

const _sentinel = Object();

class MyInstagramsFeedState {
  const MyInstagramsFeedState({
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

  MyInstagramsFeedState copyWith({
    List<int>? ids,
    Object? nextCursor = _sentinel,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return MyInstagramsFeedState(
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

class MyInstagramsFeedViewData {
  const MyInstagramsFeedViewData({
    required this.items,
    required this.isLoading,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.errorMessage,
  });

  final List<Instagram> items;
  final bool isLoading;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final String? errorMessage;
}

final fetchMyInstagramsUseCaseProvider = Provider<FetchMyInstagramsUseCase>(
  (ref) => di<FetchMyInstagramsUseCase>(),
);

final deleteInstagramUseCaseProvider = Provider<DeleteInstagramUseCase>(
  (ref) => di<DeleteInstagramUseCase>(),
);

final updateInstagramUseCaseProvider = Provider<UpdateInstagramUseCase>(
  (ref) => di<UpdateInstagramUseCase>(),
);

final myInstagramsStoreProvider =
    StateNotifierProvider<MyInstagramsStore, MyInstagramsState>((ref) {
      return MyInstagramsStore(
        ref.watch(fetchMyInstagramsUseCaseProvider),
        ref.watch(deleteInstagramUseCaseProvider),
        ref.watch(updateInstagramUseCaseProvider),
      );
    });

final myInstagramsFeedProvider = Provider<MyInstagramsFeedViewData>((ref) {
  final state = ref.watch(myInstagramsStoreProvider);
  final feed = state.feed;
  final items = feed.ids
      .map((id) => state.entities[id])
      .whereType<Instagram>()
      .toList();
  final isInitialLoading = feed.isLoading && items.isEmpty;
  return MyInstagramsFeedViewData(
    items: items,
    isLoading: feed.isLoading,
    isInitialLoading: isInitialLoading,
    isLoadingMore: feed.isLoadingMore,
    hasNext: feed.hasNext,
    errorMessage: feed.errorMessage,
  );
});
