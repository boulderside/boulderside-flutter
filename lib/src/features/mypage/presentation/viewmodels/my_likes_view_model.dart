import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_boulder_like_use_case.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/toggle_route_like_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/usecases/fetch_liked_routes_use_case.dart';
import 'package:flutter/foundation.dart';

class MyLikesViewModel extends ChangeNotifier {
  MyLikesViewModel(this._fetchLikedRoutes, this._fetchLikedBoulders, this._toggleRouteLike, this._toggleBoulderLike);

  final FetchLikedRoutesUseCase _fetchLikedRoutes;
  final FetchLikedBouldersUseCase _fetchLikedBoulders;
  final ToggleRouteLikeUseCase _toggleRouteLike;
  final ToggleBoulderLikeUseCase _toggleBoulderLike;

  final List<RouteModel> _routes = <RouteModel>[];
  final List<BoulderModel> _boulders = <BoulderModel>[];

  bool _isLoadingRoutes = false;
  bool _isLoadingMoreRoutes = false;
  bool _routeHasNext = true;
  int? _routeCursor;
  String? _routeError;

  bool _isLoadingBoulders = false;
  bool _isLoadingMoreBoulders = false;
  bool _boulderHasNext = true;
  int? _boulderCursor;
  String? _boulderError;

  bool get isLoadingRoutes => _isLoadingRoutes;
  bool get isLoadingBoulders => _isLoadingBoulders;
  bool get isLoadingMoreRoutes => _isLoadingMoreRoutes;
  bool get isLoadingMoreBoulders => _isLoadingMoreBoulders;
  bool get routeHasNext => _routeHasNext;
  bool get boulderHasNext => _boulderHasNext;
  String? get routeError => _routeError;
  String? get boulderError => _boulderError;

  List<RouteModel> get routes => List.unmodifiable(_routes);
  List<BoulderModel> get boulders => List.unmodifiable(_boulders);

  Future<void> loadInitial() async {
    await Future.wait([loadRoutes(force: true), loadBoulders(force: true)]);
  }

  Future<void> loadRoutes({bool force = false}) async {
    if (_isLoadingRoutes) return;
    if (!force && _routes.isNotEmpty) return;

    _isLoadingRoutes = true;
    _routeError = null;
    notifyListeners();

    final result = await _fetchLikedRoutes(cursor: null);
    result.when(
      success: (page) {
        _routes
          ..clear()
          ..addAll(page.items);
        _routeCursor = page.nextCursor;
        _routeHasNext = page.hasNext;
      },
      failure: (failure) {
        _routeError = failure.message;
        _routes.clear();
      },
    );

    _isLoadingRoutes = false;
    notifyListeners();
  }

  Future<void> refreshRoutes() => loadRoutes(force: true);

  Future<void> loadMoreRoutes() async {
    if (_isLoadingMoreRoutes || !_routeHasNext) return;
    _isLoadingMoreRoutes = true;
    notifyListeners();
    try {
      final result = await _fetchLikedRoutes(cursor: _routeCursor);
      result.when(
        success: (page) {
          _routes.addAll(page.items);
          _routeCursor = page.nextCursor;
          _routeHasNext = page.hasNext;
        },
        failure: (failure) {
          _routeError = failure.message;
        },
      );
    } finally {
      _isLoadingMoreRoutes = false;
      notifyListeners();
    }
  }

  Future<void> loadBoulders({bool force = false}) async {
    if (_isLoadingBoulders) return;
    if (!force && _boulders.isNotEmpty) return;

    _isLoadingBoulders = true;
    _boulderError = null;
    notifyListeners();

    final result = await _fetchLikedBoulders(cursor: null);
    result.when(
      success: (page) {
        _boulders
          ..clear()
          ..addAll(page.items);
        _boulderCursor = page.nextCursor;
        _boulderHasNext = page.hasNext;
      },
      failure: (failure) {
        _boulderError = failure.message;
        _boulders.clear();
      },
    );

    _isLoadingBoulders = false;
    notifyListeners();
  }

  Future<void> refreshBoulders() => loadBoulders(force: true);

  Future<void> loadMoreBoulders() async {
    if (_isLoadingMoreBoulders || !_boulderHasNext) return;
    _isLoadingMoreBoulders = true;
    notifyListeners();
    try {
      final result = await _fetchLikedBoulders(cursor: _boulderCursor);
      result.when(
        success: (page) {
          _boulders.addAll(page.items);
          _boulderCursor = page.nextCursor;
          _boulderHasNext = page.hasNext;
        },
        failure: (failure) {
          _boulderError = failure.message;
        },
      );
    } finally {
      _isLoadingMoreBoulders = false;
      notifyListeners();
    }
  }

  Future<void> toggleRouteLike(int routeId) async {
    _routes.removeWhere((route) => route.id == routeId);
    notifyListeners();
    try {
      await _toggleRouteLike(routeId);
    } catch (e) {
      debugPrint('Failed to toggle route like: $e');
      await loadRoutes(force: true);
    }
  }

  Future<void> toggleBoulderLike(int boulderId) async {
    _boulders.removeWhere((boulder) => boulder.id == boulderId);
    notifyListeners();
    try {
      await _toggleBoulderLike(boulderId);
    } catch (e) {
      debugPrint('Failed to toggle boulder like: $e');
      await loadBoulders(force: true);
    }
  }
}
