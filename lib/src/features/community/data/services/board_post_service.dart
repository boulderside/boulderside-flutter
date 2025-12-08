import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:dio/dio.dart';

enum BoardPostSort {
  latestCreated,
  mostViewed,
}

extension BoardPostSortX on BoardPostSort {
  String get apiValue {
    switch (this) {
      case BoardPostSort.latestCreated:
        return 'LATEST_CREATED';
      case BoardPostSort.mostViewed:
        return 'MOST_VIEWED';
    }
  }
}

class BoardPostService {
  BoardPostService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<BoardPostPageResponse> fetchPosts({
    int? cursor,
    String? subCursor,
    int size = 5,
    BoardPostSort sort = BoardPostSort.latestCreated,
  }) async {
    final queryParams = <String, dynamic>{
      'size': size,
      'postSortType': sort.apiValue,
    };

    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    if (subCursor != null) {
      queryParams['subCursor'] = subCursor;
    }

    final response = await _dio.get('/board-posts/page', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoardPostPageResponse.fromJson(data);
    }
    throw Exception('Failed to fetch board posts');
  }

  Future<BoardPostPageResponse> fetchMyPosts({
    int? cursor,
    int size = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'size': size,
    };

    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _dio.get('/board-posts/me', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoardPostPageResponse.fromJson(data);
    }
    throw Exception('Failed to fetch my board posts');
  }

  Future<BoardPostResponse> fetchPost(int id) async {
    final response = await _dio.get('/board-posts/$id');

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoardPostResponse.fromJson(data);
    }
    throw Exception('Failed to fetch board post');
  }

  Future<BoardPostResponse> createPost(CreateBoardPostRequest request) async {
    final response = await _dio.post('/board-posts', data: request.toJson());

    if (response.statusCode == 201) {
      final data = response.data['data'];
      return BoardPostResponse.fromJson(data);
    }
    throw Exception('Failed to create board post');
  }

  Future<BoardPostResponse> updatePost(
    int id,
    UpdateBoardPostRequest request,
  ) async {
    final response = await _dio.put('/board-posts/$id', data: request.toJson());

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return BoardPostResponse.fromJson(data);
    }
    throw Exception('Failed to update board post');
  }

  Future<void> deletePost(int id) async {
    final response = await _dio.delete('/board-posts/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete board post');
    }
  }
}
