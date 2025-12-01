import 'package:boulderside_flutter/community/models/mate_post_models.dart';
import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:dio/dio.dart';

enum MatePostSort {
  latestCreated,
  mostViewed,
  nearestMeetingDate,
}

extension MatePostSortX on MatePostSort {
  String get apiValue {
    switch (this) {
      case MatePostSort.latestCreated:
        return 'LATEST_CREATED';
      case MatePostSort.mostViewed:
        return 'MOST_VIEWED';
      case MatePostSort.nearestMeetingDate:
        return 'NEAREST_MEETING_DATE';
    }
  }
}

class MatePostService {
  MatePostService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<MatePostPageResponse> fetchPosts({
    int? cursor,
    String? subCursor,
    int size = 5,
    MatePostSort sort = MatePostSort.latestCreated,
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

    final response = await _dio.get('/mate-posts', queryParameters: queryParams);

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return MatePostPageResponse.fromJson(data);
    }
    throw Exception('Failed to fetch mate posts');
  }

  Future<MatePostResponse> fetchPost(int id) async {
    final response = await _dio.get('/mate-posts/$id');

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return MatePostResponse.fromJson(data);
    }
    throw Exception('Failed to fetch mate post');
  }

  Future<MatePostResponse> createPost(CreateMatePostRequest request) async {
    final response = await _dio.post('/mate-posts', data: request.toJson());

    if (response.statusCode == 201) {
      final data = response.data['data'];
      return MatePostResponse.fromJson(data);
    }
    throw Exception('Failed to create mate post');
  }

  Future<MatePostResponse> updatePost(
    int id,
    UpdateMatePostRequest request,
  ) async {
    final response = await _dio.put('/mate-posts/$id', data: request.toJson());

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return MatePostResponse.fromJson(data);
    }
    throw Exception('Failed to update mate post');
  }

  Future<void> deletePost(int id) async {
    final response = await _dio.delete('/mate-posts/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete mate post');
    }
  }
}
