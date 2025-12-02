import 'package:boulderside_flutter/src/domain/entities/route_model.dart';

class LikedRoutePage {
  const LikedRoutePage({required this.items, required this.nextCursor, required this.hasNext});

  final List<RouteModel> items;
  final int? nextCursor;
  final bool hasNext;
}
