import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';

class LikedInstagramPage {
  const LikedInstagramPage({
    required this.items,
    this.nextCursor,
    required this.hasNext,
  });

  final List<Instagram> items;
  final int? nextCursor;
  final bool hasNext;
}
