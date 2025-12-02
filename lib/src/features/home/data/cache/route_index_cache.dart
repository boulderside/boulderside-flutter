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
}
