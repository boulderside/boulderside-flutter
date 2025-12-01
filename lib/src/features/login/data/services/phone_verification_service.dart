import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/phone_verification_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/verify_phone_code_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/find_id_by_phone_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/response/find_id_response.dart';
import 'package:dio/dio.dart';

class PhoneVerificationService {
  PhoneVerificationService() : _dio = ApiClient.dio;
  final Dio _dio;

  static const String _basePath = '/users';

  // 전화번호 인증 코드 전송
  Future<void> sendPhoneVerificationCode(String phoneNumber) async {
    try {
      final request = PhoneVerificationRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/phone/send-code',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send phone verification code');
      }
    } catch (e) {
      throw Exception('전화번호 인증 코드 전송 실패: $e');
    }
  }

  // 전화번호 인증 코드 검증
  Future<bool> verifyPhoneVerificationCode(
    String phoneNumber,
    String code,
  ) async {
    try {
      final request = VerifyPhoneCodeRequest(
        phoneNumber: phoneNumber,
        code: code,
      );
      final response = await _dio.post(
        '$_basePath/phone/verify-code',
        data: request.toJson(),
      );

      return response.data['data'] ?? false;
    } catch (e) {
      throw Exception('전화번호 인증 코드 검증 실패: $e');
    }
  }

  // 휴대폰 번호로 아이디 찾기
  Future<FindIdResponse> findIdByPhone(String phoneNumber) async {
    try {
      final request = FindIdByPhoneRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/find-id',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to find ID by phone');
      }

      // ApiResponse<FindIdByPhoneResponse> 구조에서 data 필드 추출
      final responseData = response.data['data'];
      if (responseData == null) {
        throw Exception('응답 데이터가 없습니다');
      }

      return FindIdResponse.fromJson(responseData);
    } catch (e) {
      throw Exception('아이디 찾기 실패: $e');
    }
  }
}
