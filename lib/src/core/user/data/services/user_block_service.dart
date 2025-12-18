import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/core/user/models/blocked_user.dart';

class UserBlockService {
  UserBlockService(Dio dio) : _dio = dio;

  final Dio _dio;
  static const String _path = '/users/me/blocks';

  Future<List<BlockedUser>> fetchBlockedUsers() async {
    final response = await _dio.get(_path);
    if (response.statusCode == 200) {
      final data = response.data['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(BlockedUser.fromJson)
            .toList();
      }
    }
    throw Exception('차단한 사용자를 불러오지 못했습니다.');
  }

  Future<void> blockUser(int targetUserId) async {
    final response = await _dio.post(
      _path,
      data: {'targetUserId': targetUserId},
    );
    if ((response.statusCode ?? 500) >= 400) {
      throw Exception('사용자를 차단하지 못했습니다.');
    }
  }

  Future<void> unblockUser(int blockedUserId) async {
    final response = await _dio.delete('$_path/$blockedUserId');
    if ((response.statusCode ?? 500) >= 400) {
      throw Exception('사용자 차단을 해제하지 못했습니다.');
    }
  }
}
