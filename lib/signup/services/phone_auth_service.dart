import 'package:boulderside_flutter/core/api/api_client.dart';
import 'package:boulderside_flutter/signup/models/request/phone_auth_request.dart';
import 'package:boulderside_flutter/signup/models/request/verify_code_request.dart';
import 'package:dio/dio.dart';

class PhoneAuthService {
  PhoneAuthService() : _dio = ApiClient.dio;
  final Dio _dio;

  static const String _basePath = '/users';

  // 전화번호 인증 코드 전송
  Future<void> sendPhoneAuthCode(String phoneNumber) async {
    try {
      final request = PhoneAuthRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/phone/send-code',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send phone auth code');
      }
    } catch (e) {
      throw Exception('전화번호 인증 코드 전송 실패: $e');
    }
  }

  // 전화번호 인증 코드 검증
  Future<bool> verifyPhoneAuthCode(String phoneNumber, String code) async {
    try {
      final request = VerifyCodeRequest(phoneNumber: phoneNumber, code: code);
      final response = await _dio.post(
        '$_basePath/phone/verify-code',
        data: request.toJson(),
      );

      return response.data['data'] ?? false;
    } catch (e) {
      throw Exception('전화번호 인증 코드 검증 실패: $e');
    }
  }
}
