import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_comment_page.dart';

abstract class MyCommentsRepository {
  Future<Result<MyCommentPage>> fetchMyComments({int? cursor, int size});
}
