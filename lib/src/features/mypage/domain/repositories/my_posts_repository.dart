import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_board_posts_page.dart';
import 'package:boulderside_flutter/src/features/mypage/domain/models/my_mate_posts_page.dart';

abstract class MyPostsRepository {
  Future<Result<MyBoardPostsPage>> fetchMyBoardPosts({int? cursor, int size});

  Future<Result<MyMatePostsPage>> fetchMyMatePosts({int? cursor, int size});
}
