import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/route_completion_service.dart';
import 'package:flutter/foundation.dart';

class RouteCompletionViewModel extends ChangeNotifier {
  RouteCompletionViewModel(this._completionService, this._routeIndexCache);

  final RouteCompletionService _completionService;
  final RouteIndexCache _routeIndexCache;

  final List<RouteCompletionModel> _completions = [];
  final Map<int, RouteModel> _routeCache = {};
  List<RouteModel> _allRoutes = <RouteModel>[];

  bool _isLoading = false;
  bool _isMutating = false;
  bool _isRouteIndexLoading = false;
  String? _errorMessage;
  String? _routeIndexError;

  List<RouteCompletionModel> get completions =>
      List.unmodifiable(_completions.map(_attachRoute));
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;

  bool get isRouteIndexLoading => _isRouteIndexLoading;
  String? get routeIndexError => _routeIndexError;
  List<RouteModel> get availableRoutes => List.unmodifiable(_allRoutes);

  Future<void> loadCompletions() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _completionService.fetchCompletions();
      _completions
        ..clear()
        ..addAll(items);
    } catch (e) {
      debugPrint('Failed to load completions: $e');
      _errorMessage = '내 등반 기록을 불러오지 못했습니다.';
      _completions.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_allRoutes.isEmpty && !_isRouteIndexLoading) {
      ensureRouteIndexLoaded();
    }
  }

  Future<void> refresh() => loadCompletions();

  Future<void> ensureRouteIndexLoaded() async {
    if (_allRoutes.isNotEmpty || _isRouteIndexLoading) {
      return;
    }

    _isRouteIndexLoading = true;
    _routeIndexError = null;
    notifyListeners();

    try {
      final routes = await _routeIndexCache.load();
      _allRoutes = routes;
      _routeCache
        ..clear()
        ..addEntries(routes.map((route) => MapEntry(route.id, route)));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load routes: $e');
      _routeIndexError = '루트 목록을 불러오지 못했습니다.';
    } finally {
      _isRouteIndexLoading = false;
      notifyListeners();
    }
  }

  Future<RouteCompletionModel> addCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    _isMutating = true;
    notifyListeners();
    try {
      final result = await _completionService.createCompletion(
        routeId: routeId,
        completed: completed,
        memo: memo,
      );
      _replaceOrAdd(_attachRoute(result), insertFirst: true);
      return result;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<RouteCompletionModel> updateCompletion({
    required int routeId,
    required bool completed,
    String? memo,
  }) async {
    _isMutating = true;
    notifyListeners();
    try {
      final result = await _completionService.updateCompletion(
        routeId: routeId,
        completed: completed,
        memo: memo,
      );
      _replaceOrAdd(_attachRoute(result));
      return result;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<void> deleteCompletion(int routeId) async {
    _isMutating = true;
    notifyListeners();
    try {
      await _completionService.deleteCompletion(routeId);
      _completions.removeWhere((item) => item.routeId == routeId);
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  RouteModel? routeById(int routeId) => _routeCache[routeId];

  RouteCompletionModel _attachRoute(RouteCompletionModel completion) {
    final route = _routeCache[completion.routeId];
    if (route == null || completion.route == route) {
      return completion;
    }
    return completion.copyWith(route: route);
  }

  void _replaceOrAdd(
    RouteCompletionModel completion, {
    bool insertFirst = false,
  }) {
    final index = _completions.indexWhere(
      (item) => item.routeId == completion.routeId,
    );
    if (index >= 0) {
      _completions[index] = completion;
    } else if (insertFirst) {
      _completions.insert(0, completion);
    } else {
      _completions.add(completion);
    }
  }
}
