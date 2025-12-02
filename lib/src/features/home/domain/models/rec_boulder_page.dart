import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';

class RecBoulderPage {
  const RecBoulderPage({
    required this.items,
    required this.nextCursor,
    required this.nextSubCursor,
    required this.hasNext,
  });

  final List<BoulderModel> items;
  final int? nextCursor;
  final String? nextSubCursor;
  final bool hasNext;
}
