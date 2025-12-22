import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';

class RouteInstagram {
  const RouteInstagram({
    required this.routeInstagramId,
    required this.routeId,
    required this.instagramId,
    required this.instagram,
    this.createdAt,
    this.updatedAt,
  });

  final int routeInstagramId;
  final int routeId;
  final int instagramId;
  final Instagram instagram;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
