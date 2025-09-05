import 'package:boulderside_flutter/community/models/post_models.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

class PostService {
  PostService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<PostPageResponse> getPostPage({
    int? cursor,
    String? subCursor,
    int size = 5,
    required PostType postType,
    PostSortType postSortType = PostSortType.latestCreated,
  }) async {
    final queryParams = <String, dynamic>{
      'size': size,
      'postType': postType.name.toUpperCase(),
      'postSortType': _convertPostSortTypeToApi(postSortType),
    };

    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    if (subCursor != null) {
      queryParams['subCursor'] = subCursor;
    }

    final response = await _dio.get(
      '/posts',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return PostPageResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<PostResponse> getPost(int id) async {
    final response = await _dio.get('/posts/$id');

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return PostResponse.fromJson(data);
    } else {
      throw Exception('Failed to fetch post');
    }
  }

  Future<PostResponse> createPost(CreatePostRequest request) async {
    final response = await _dio.post(
      '/posts',
      data: request.toJson(),
    );

    if (response.statusCode == 201) {
      final data = response.data['data'];
      return PostResponse.fromJson(data);
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<PostResponse> updatePost(int id, UpdatePostRequest request) async {
    final response = await _dio.put(
      '/posts/$id',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return PostResponse.fromJson(data);
    } else {
      throw Exception('Failed to update post');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await _dio.delete('/posts/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete post');
    }
  }

  String _convertPostSortTypeToApi(PostSortType sortType) {
    switch (sortType) {
      case PostSortType.latestCreated:
        return 'LATEST_CREATED';
      case PostSortType.mostViewed:
        return 'MOST_VIEWED';
      case PostSortType.nearestMeetingDate:
        return 'NEAREST_MEETING_DATE';
    }
  }
}