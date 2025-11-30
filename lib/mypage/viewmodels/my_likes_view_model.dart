import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/mypage/services/my_likes_service.dart';
import 'package:flutter/foundation.dart';

class MyLikesViewModel extends ChangeNotifier {
  MyLikesViewModel(this._service);

  final MyLikesService _service;

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
    await Future.wait([
      loadRoutes(force: true),
      loadBoulders(force: true),
    ]);
  }

  Future<void> loadRoutes({bool force = false}) async {
    if (_isLoadingRoutes) return;
    if (!force && _routes.isNotEmpty) return;

    _isLoadingRoutes = true;
    _routeError = null;
    notifyListeners();

    try {
      final response = await _service.fetchLikedRoutes(cursor: null);
      _routes
        ..clear()
        ..addAll(response.content);
      _routeCursor = response.nextCursor;
      _routeHasNext = response.hasNext;
    } catch (e) {
      debugPrint('Failed to load liked routes: $e');
      _routeError = '좋아요한 루트를 불러오지 못했습니다.';
      _routes.clear();
    } finally {
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  Future<void> refreshRoutes() => loadRoutes(force: true);

  Future<void> loadMoreRoutes() async {
    if (_isLoadingMoreRoutes || !_routeHasNext) return;
    _isLoadingMoreRoutes = true;
    notifyListeners();
    try {
      final response =
          await _service.fetchLikedRoutes(cursor: _routeCursor);
      _routes.addAll(response.content);
      _routeCursor = response.nextCursor;
      _routeHasNext = response.hasNext;
    } catch (e) {
      debugPrint('Failed to load more liked routes: $e');
      _routeError = '추가 루트를 불러오지 못했습니다.';
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

    try {
      final response = await _service.fetchLikedBoulders(cursor: null);
      _boulders
        ..clear()
        ..addAll(response.content);
      _boulderCursor = response.nextCursor;
      _boulderHasNext = response.hasNext;
    } catch (e) {
      debugPrint('Failed to load liked boulders: $e');
      _boulderError = '좋아요한 바위를 불러오지 못했습니다.';
      _boulders.clear();
    } finally {
      _isLoadingBoulders = false;
      notifyListeners();
    }
  }

  Future<void> refreshBoulders() => loadBoulders(force: true);

  Future<void> loadMoreBoulders() async {
    if (_isLoadingMoreBoulders || !_boulderHasNext) return;
    _isLoadingMoreBoulders = true;
    notifyListeners();
    try {
      final response =
          await _service.fetchLikedBoulders(cursor: _boulderCursor);
      _boulders.addAll(response.content);
      _boulderCursor = response.nextCursor;
      _boulderHasNext = response.hasNext;
    } catch (e) {
      debugPrint('Failed to load more liked boulders: $e');
      _boulderError = '추가 바위를 불러오지 못했습니다.';
    } finally {
      _isLoadingMoreBoulders = false;
      notifyListeners();
    }
  }

  Future<void> toggleRouteLike(int routeId) async {
    _routes.removeWhere((route) => route.id == routeId);
    notifyListeners();
    try {
      await _service.toggleRouteLike(routeId);
    } catch (e) {
      debugPrint('Failed to toggle route like: $e');
      await loadRoutes(force: true);
    }
  }

  Future<void> toggleBoulderLike(int boulderId) async {
    _boulders.removeWhere((boulder) => boulder.id == boulderId);
    notifyListeners();
    try {
      await _service.toggleBoulderLike(boulderId);
    } catch (e) {
      debugPrint('Failed to toggle boulder like: $e');
      await loadBoulders(force: true);
    }
  }
}
