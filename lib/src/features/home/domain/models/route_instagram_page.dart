import 'package:boulderside_flutter/src/features/home/domain/models/route_instagram.dart';

class RouteInstagramPage {
  const RouteInstagramPage({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<RouteInstagram> items;
  final int? nextCursor;
  final bool hasNext;
}
