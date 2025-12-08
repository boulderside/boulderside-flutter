import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';

class MyBoardPostsPage {
  const MyBoardPostsPage({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<BoardPostResponse> items;
  final int? nextCursor;
  final bool hasNext;
}
