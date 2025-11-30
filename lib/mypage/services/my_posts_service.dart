import 'package:boulderside_flutter/community/models/post_models.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class MyPostsService {
  MyPostsService() : _dio = ApiClient.dio;

  final Dio _dio;

  Future<PostPageResponse> fetchMyPosts({
    int? cursor,
    int size = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'size': size,
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _dio.get(
      '/posts/me',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return PostPageResponse.fromJson(data);
    }
    throw Exception('내 게시글을 불러오지 못했습니다.');
  }
}
