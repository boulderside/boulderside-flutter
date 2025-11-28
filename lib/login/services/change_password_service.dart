import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/login/models/request/change_password_request.dart';
import 'package:dio/dio.dart';

class ChangePasswordService {
  ChangePasswordService() : _dio = ApiClient.dio;
  final Dio _dio;

  static const String _basePath = '/users';

  // 비밀번호 변경
  Future<void> changePassword(String phoneNumber, String newPassword) async {
    try {
      final request = ChangePasswordRequest(
        phoneNumber: phoneNumber,
        newPassword: newPassword,
      );

      final response = await _dio.patch(
        '$_basePath/change-password',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      throw Exception('비밀번호 변경 실패: $e');
    }
  }
}
