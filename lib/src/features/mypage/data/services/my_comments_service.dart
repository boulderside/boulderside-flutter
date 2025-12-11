import 'package:boulderside_flutter/src/features/community/data/models/comment_models.dart';
import 'package:dio/dio.dart';

class MyCommentsService {
  MyCommentsService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<CommentPageResponseModel> fetchMyComments({
    int? cursor,
    int size = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'size': size,
      if (cursor != null) 'cursor': cursor,
    };

    final response = await _dio.get(
      '/comments/me',
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      final data = response.data['data'];
      return CommentPageResponseModel.fromJson(data);
    }
    throw Exception('내 댓글을 불러오지 못했습니다.');
  }
}
