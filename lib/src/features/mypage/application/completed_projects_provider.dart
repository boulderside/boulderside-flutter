import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final completedCompletionsProvider =
    StateNotifierProvider.autoDispose<
      CompletedCompletionsNotifier,
      CompletedCompletionsState
    >((ref) {
      return CompletedCompletionsNotifier(di<CompletionService>());
    });

class CompletedCompletionsNotifier
    extends StateNotifier<CompletedCompletionsState> {
  CompletedCompletionsNotifier(this._service)
    : super(const CompletedCompletionsState());

  final CompletionService _service;

  Future<void> loadInitial() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      completions: const <CompletionResponse>[],
      nextCursor: null,
      hasNext: true,
    );
    try {
      final page = await _service.fetchCompletionPage(size: 10);
      state = state.copyWith(
        completions: page.content,
        isLoading: false,
        nextCursor: page.nextCursor,
        hasNext: page.hasNext,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '완등 목록을 불러오지 못했어요.',
      );
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasNext || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _service.fetchCompletionPage(
        cursor: state.nextCursor,
        size: 10,
      );
      state = state.copyWith(
        completions: [...state.completions, ...page.content],
        isLoadingMore: false,
        nextCursor: page.nextCursor,
        hasNext: page.hasNext,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

class CompletedCompletionsState {
  const CompletedCompletionsState({
    this.completions = const <CompletionResponse>[],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.nextCursor,
    this.errorMessage,
  });

  final List<CompletionResponse> completions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int? nextCursor;
  final String? errorMessage;

  CompletedCompletionsState copyWith({
    List<CompletionResponse>? completions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    Object? nextCursor = _sentinel,
    String? errorMessage,
  }) {
    return CompletedCompletionsState(
      completions: completions ?? this.completions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      nextCursor: identical(nextCursor, _sentinel)
          ? this.nextCursor
          : nextCursor as int?,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

const _sentinel = Object();
