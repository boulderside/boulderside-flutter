import 'package:boulderside_flutter/src/domain/entities/route_model.dart';

class PaginatedRoutes {
  const PaginatedRoutes({
    required this.items,
    required this.nextCursor,
    required this.nextSubCursor,
    required this.hasNext,
  });

  final List<RouteModel> items;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
}
