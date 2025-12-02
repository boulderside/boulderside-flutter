import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';

class MyMatePostsPage {
  const MyMatePostsPage({required this.items, required this.nextCursor, required this.hasNext});

  final List<MatePostResponse> items;
  final int? nextCursor;
  final bool hasNext;
}
