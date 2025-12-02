import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/features/search/data/models/search_models.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';

enum SearchState { initial, searching, completed, error }

class SearchViewModel extends ChangeNotifier {
  final SearchService _service;

  SearchViewModel(this._service);

  SearchState _state = SearchState.initial;
  SearchState get state => _state;

  String _query = '';
  String get query => _query;

  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  
  bool _isLoadingSuggestions = false;
  bool get isLoadingSuggestions => _isLoadingSuggestions;

  UnifiedSearchResponse? _unifiedResults;
  UnifiedSearchResponse? get unifiedResults => _unifiedResults;

  final Map<DocumentDomainType, DomainSearchResponse> _domainResults = {};
  Map<DocumentDomainType, DomainSearchResponse> get domainResults => _domainResults;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateQuery(String newQuery) {
    if (_query == newQuery) return;
    
    _query = newQuery;
    _errorMessage = null;
    
    if (_query.isEmpty) {
      _suggestions.clear();
      _state = SearchState.initial;
      _unifiedResults = null;
      _domainResults.clear();
    } else {
      _loadSuggestions();
    }
    
    notifyListeners();
  }

  Future<void> _loadSuggestions() async {
    if (_query.isEmpty) return;

    _isLoadingSuggestions = true;
    notifyListeners();

    try {
      final response = await _service.getSuggestions(_query);
      _suggestions = response.suggestionList;
      _errorMessage = null;
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  Future<void> searchUnified() async {
    if (_query.trim().isEmpty) return;

    _state = SearchState.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      _unifiedResults = await _service.searchUnified(_query.trim());
      _state = SearchState.completed;
    } finally {
      notifyListeners();
    }
  }

  Future<void> searchByDomain({
    required DocumentDomainType domain,
    int size = 10,
  }) async {
    if (_query.trim().isEmpty) return;

    _state = SearchState.searching;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.searchByDomain(
        keyword: _query.trim(),
        domain: domain,
        size: size,
      );
      _domainResults[domain] = response;
      _state = SearchState.completed;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_query.trim().isEmpty) return;
    
    _domainResults.clear();
    _unifiedResults = null;
    
    await searchUnified();
  }

  void clearSearch() {
    _query = '';
    _suggestions.clear();
    _unifiedResults = null;
    _domainResults.clear();
    _errorMessage = null;
    _state = SearchState.initial;
    notifyListeners();
  }

  void selectSuggestion(String suggestion) {
    _query = suggestion;
    _suggestions.clear();
    notifyListeners();
  }

  bool get hasResults => _unifiedResults != null || _domainResults.isNotEmpty;
  
  bool get isLoading => _state == SearchState.searching;
  
  bool get hasError => _state == SearchState.error;
  
  bool get isEmpty => _state == SearchState.completed && !hasResults;
}