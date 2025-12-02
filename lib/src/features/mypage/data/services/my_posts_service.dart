import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:dio/dio.dart';

class MyPostsService {
  MyPostsService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<BoardPostPageResponse> fetchMyBoardPosts({int? cursor, int size = 10}) async {
    final queryParameters = <String, dynamic>{'size': size, if (cursor != null) 'cursor': cursor};

    final response = await _dio.get('/board-posts/me', queryParameters: queryParameters);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoardPostPageResponse.fromJson(data);
    }
    throw Exception('내 게시글을 불러오지 못했습니다.');
  }

  Future<MatePostPageResponse> fetchMyMatePosts({int? cursor, int size = 10}) async {
    final queryParameters = <String, dynamic>{'size': size, if (cursor != null) 'cursor': cursor};

    final response = await _dio.get('/mate-posts/me', queryParameters: queryParameters);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return MatePostPageResponse.fromJson(data);
    }
    throw Exception('내 게시글을 불러오지 못했습니다.');
  }
}
