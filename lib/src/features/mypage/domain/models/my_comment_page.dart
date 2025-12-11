import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';

class MyCommentPage {
  const MyCommentPage({
    required this.items,
    required this.nextCursor,
    required this.hasNext,
  });

  final List<CommentResponseModel> items;
  final int? nextCursor;
  final bool hasNext;
}
