import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/features/mypage/data/models/notice_page_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/notice_response.dart';

class NoticeService {
  NoticeService(Dio dio) : _dio = dio;

  final Dio _dio;
  static const String _basePath = '/notices';

  Future<NoticePageResponse> fetchNotices({int page = 0, int size = 10}) async {
    final response = await _dio.get(
      _basePath,
      queryParameters: {'page': page, 'size': size},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return NoticePageResponse.fromJson(data);
      }
    }
    throw Exception('공지사항을 불러오지 못했습니다.');
  }

  Future<NoticeResponse> fetchNotice(int noticeId) async {
    final response = await _dio.get('$_basePath/$noticeId');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return NoticeResponse.fromJson(data);
      }
    }
    throw Exception('공지사항을 불러오지 못했습니다.');
  }
}
