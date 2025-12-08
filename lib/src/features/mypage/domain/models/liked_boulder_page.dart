import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';

class LikedBoulderPage {
  const LikedBoulderPage({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<BoulderModel> items;
  final int? nextCursor;
  final bool hasNext;
}
