import 'dart:async';

import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';

class RouteIndexCache {
  RouteIndexCache(this._routeService);

  final RouteService _routeService;

  Future<List<RouteModel>>? _pending;
  List<RouteModel>? _routes;

  Future<List<RouteModel>> load() {
    if (_routes != null) {
      return Future.value(_routes);
    }
    _pending ??= _routeService.fetchAllRoutes().then((value) {
      _routes = value;
      _pending = null;
      return value;
    });
    return _pending!;
  }

  void invalidate() {
    _routes = null;
    _pending = null;
  }

  Future<List<RouteModel>> refresh() {
    invalidate();
    return load();
  }

  void updateRoute(int routeId, RouteModel Function(RouteModel) updater) {
    if (_routes == null) return;

    final index = _routes!.indexWhere((route) => route.id == routeId);
    if (index >= 0) {
      _routes![index] = updater(_routes![index]);
    }
  }
}
