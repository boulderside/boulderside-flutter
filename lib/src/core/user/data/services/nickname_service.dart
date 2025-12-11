import 'dart:io';

import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/user/data/models/request/update_nickname_request.dart';

class NicknameService {
  NicknameService() : _dio = ApiClient.dio;

  final Dio _dio;

  Future<bool> checkNicknameAvailability(String nickname) async {
    final response = await _dio.get(
      '/users/nickname/availability',
      queryParameters: {'nickname': nickname},
    );

    final data = response.data['data'];
    if (data is Map<String, dynamic>) {
      final available = data['available'];
      if (available is bool) {
        return available;
      }
    }
    return false;
  }

  Future<void> updateNickname(String nickname) async {
    final request = UpdateNicknameRequest(nickname: nickname);
    await _dio.patch('/users/me/nickname', data: request.toJson());
  }

  Future<String?> updateProfileImage(File imageFile) async {
    final formData = FormData.fromMap({
      'profileImage': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _dio.patch(
      '/users/me/profile-image',
      data: formData,
    );

    final data = response.data['data'];
    if (data is Map<String, dynamic>) {
      return data['profileImageUrl'] as String?;
    }
    return null;
  }
}
