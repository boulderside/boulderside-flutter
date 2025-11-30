import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/mypage/services/my_likes_service.dart';
import 'package:flutter/foundation.dart';

class MyLikesViewModel extends ChangeNotifier {
  MyLikesViewModel(this._service);

  final MyLikesService _service;

  List<RouteModel> _routes = <RouteModel>[];
  List<BoulderModel> _boulders = <BoulderModel>[];

  bool _isLoadingRoutes = false;
  bool _isLoadingBoulders = false;
  String? _routeError;
  String? _boulderError;

  bool get isLoadingRoutes => _isLoadingRoutes;
  bool get isLoadingBoulders => _isLoadingBoulders;
  String? get routeError => _routeError;
  String? get boulderError => _boulderError;

  List<RouteModel> get routes => List.unmodifiable(_routes);
  List<BoulderModel> get boulders => List.unmodifiable(_boulders);

  Future<void> loadLikes() async {
    await Future.wait([
      loadRoutes(force: true),
      loadBoulders(force: true),
    ]);
  }

  Future<void> loadRoutes({bool force = false}) async {
    if (_isLoadingRoutes || (!force && _routes.isNotEmpty)) return;
    _isLoadingRoutes = true;
    _routeError = null;
    notifyListeners();
    try {
      _routes = await _service.fetchLikedRoutes();
    } catch (e) {
      debugPrint('Failed to load liked routes: $e');
      _routeError = '좋아요한 루트를 불러오는 데 실패했습니다.';
      _routes = <RouteModel>[];
    } finally {
      _isLoadingRoutes = false;
      notifyListeners();
    }
  }

  Future<void> loadBoulders({bool force = false}) async {
    if (_isLoadingBoulders || (!force && _boulders.isNotEmpty)) return;
    _isLoadingBoulders = true;
    _boulderError = null;
    notifyListeners();
    try {
      _boulders = await _service.fetchLikedBoulders();
    } catch (e) {
      debugPrint('Failed to load liked boulders: $e');
      _boulderError = '좋아요한 바위를 불러오는 데 실패했습니다.';
      _boulders = <BoulderModel>[];
    } finally {
      _isLoadingBoulders = false;
      notifyListeners();
    }
  }

  Future<void> refreshRoutes() => loadRoutes(force: true);
  Future<void> refreshBoulders() => loadBoulders(force: true);
}
