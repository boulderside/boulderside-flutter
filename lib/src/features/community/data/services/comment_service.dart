import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:dio/dio.dart';

class CommentService {
  CommentService() : _dio = ApiClient.dio;
  final Dio _dio;

  Future<CommentPageResponseModel> getComments({
    required String domainType,
    required int domainId,
    int? cursor,
    int size = 10,
  }) async {
    final queryParams = <String, dynamic>{'size': size};

    if (cursor != null) {
      queryParams['cursor'] = cursor;
    }

    final response = await _dio.get(
      '/comments/$domainType/$domainId',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return CommentPageResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch comments');
    }
  }

  Future<CommentResponseModel> createComment({
    required String domainType,
    required int domainId,
    required String content,
  }) async {
    final request = CreateCommentRequest(content: content);

    final response = await _dio.post(
      '/comments/$domainType/$domainId',
      data: request.toJson(),
    );

    if (response.statusCode == 201) {
      final data = response.data['data'];
      return CommentResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to create comment');
    }
  }

  Future<CommentResponseModel> updateComment({
    required String domainType,
    required int domainId,
    required int commentId,
    required String content,
  }) async {
    final request = UpdateCommentRequest(content: content);

    final response = await _dio.put(
      '/comments/$domainType/$domainId/$commentId',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return CommentResponseModel.fromJson(data);
    } else {
      throw Exception('Failed to update comment');
    }
  }

  Future<void> deleteComment({
    required String domainType,
    required int domainId,
    required int commentId,
  }) async {
    final response = await _dio.delete(
      '/comments/$domainType/$domainId/$commentId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }
}
