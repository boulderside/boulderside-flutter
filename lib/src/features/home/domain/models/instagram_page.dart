import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';

class InstagramPage {
  const InstagramPage({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<Instagram> items;
  final int? nextCursor;
  final bool hasNext;

  InstagramPage copyWith({
    List<Instagram>? items,
    int? nextCursor,
    bool? hasNext,
  }) {
    return InstagramPage(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}
