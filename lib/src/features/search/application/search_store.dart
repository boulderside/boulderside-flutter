import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/search/data/models/search_models.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchStore extends StateNotifier<SearchStoreState> {
  SearchStore(this._service) : super(const SearchStoreState());

  final SearchService _service;

  void updateQuery(String newQuery) {
    if (state.query == newQuery) return;

    if (newQuery.isEmpty) {
      state = const SearchStoreState();
      return;
    }

    state = state.copyWith(query: newQuery, errorMessage: null);
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final query = state.query;
    if (query.isEmpty) return;

    state = state.copyWith(isLoadingSuggestions: true);
    try {
      final response = await _service.getSuggestions(query);
      state = state.copyWith(
        suggestions: response.suggestionList,
        errorMessage: null,
      );
    } finally {
      state = state.copyWith(isLoadingSuggestions: false);
    }
  }

  Future<void> searchUnified() async {
    final query = state.query.trim();
    if (query.isEmpty) return;

    state = state.copyWith(status: SearchStatus.searching, errorMessage: null);

    try {
      final results = await _service.searchUnified(query);
      state = state.copyWith(
        unifiedResults: results,
        status: SearchStatus.completed,
      );
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> searchByDomain({
    required DocumentDomainType domain,
    int size = 10,
  }) async {
    final query = state.query.trim();
    if (query.isEmpty) return;

    state = state.copyWith(status: SearchStatus.searching, errorMessage: null);

    try {
      final response = await _service.searchByDomain(
        keyword: query,
        domain: domain,
        size: size,
      );
      final next = Map<DocumentDomainType, DomainSearchResponse>.from(
        state.domainResults,
      )..[domain] = response;

      state = state.copyWith(
        domainResults: next,
        status: SearchStatus.completed,
      );
    } catch (error) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refresh() async {
    final query = state.query.trim();
    if (query.isEmpty) return;

    state = state.copyWith(
      domainResults: const <DocumentDomainType, DomainSearchResponse>{},
      unifiedResults: null,
    );
    await searchUnified();
  }

  void clearSearch() {
    state = const SearchStoreState();
  }

  void selectSuggestion(String suggestion) {
    state = state.copyWith(query: suggestion, suggestions: const <String>[]);
  }
}

enum SearchStatus { initial, searching, completed, error }

const _sentinel = Object();

class SearchStoreState {
  const SearchStoreState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.suggestions = const <String>[],
    this.isLoadingSuggestions = false,
    this.unifiedResults,
    this.domainResults = const <DocumentDomainType, DomainSearchResponse>{},
    this.errorMessage,
  });

  final SearchStatus status;
  final String query;
  final List<String> suggestions;
  final bool isLoadingSuggestions;
  final UnifiedSearchResponse? unifiedResults;
  final Map<DocumentDomainType, DomainSearchResponse> domainResults;
  final String? errorMessage;

  bool get hasResults => unifiedResults != null || domainResults.isNotEmpty;

  bool get isLoading => status == SearchStatus.searching;

  bool get hasError => status == SearchStatus.error;

  bool get isEmpty => status == SearchStatus.completed && !hasResults;

  SearchStoreState copyWith({
    SearchStatus? status,
    String? query,
    List<String>? suggestions,
    bool? isLoadingSuggestions,
    Object? unifiedResults = _sentinel,
    Map<DocumentDomainType, DomainSearchResponse>? domainResults,
    Object? errorMessage = _sentinel,
  }) {
    return SearchStoreState(
      status: status ?? this.status,
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      unifiedResults: identical(unifiedResults, _sentinel)
          ? this.unifiedResults
          : unifiedResults as UnifiedSearchResponse?,
      domainResults: domainResults ?? this.domainResults,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

final searchServiceProvider = Provider<SearchService>((ref) {
  return di<SearchService>();
});

final searchStoreProvider =
    StateNotifierProvider<SearchStore, SearchStoreState>((ref) {
      final service = ref.watch(searchServiceProvider);
      return SearchStore(service);
    });
