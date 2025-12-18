import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/features/mypage/data/models/report_category.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/report_page_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/report_target_type.dart';

class ReportService {
  ReportService(Dio dio) : _dio = dio;

  final Dio _dio;

  Future<void> createReport({
    required ReportTargetType targetType,
    required int targetId,
    required ReportCategory category,
    required String reason,
  }) async {
    final response = await _dio.post(
      '/reports',
      data: {
        'targetType': targetType.serverValue,
        'targetId': targetId,
        'category': category.serverValue,
        'reason': reason,
      },
    );

    if ((response.statusCode ?? 500) >= 400) {
      throw Exception('신고 접수에 실패했습니다.');
    }
  }

  Future<ReportPageResponse> fetchMyReports({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/reports/me',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return ReportPageResponse.fromJson(data);
      }
    }
    throw Exception('신고 내역을 불러오지 못했습니다.');
  }
}
