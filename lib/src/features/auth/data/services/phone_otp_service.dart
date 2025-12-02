import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/find_id_by_phone_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/phone_verification_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/verify_phone_code_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/response/find_id_response.dart';
import 'package:dio/dio.dart';

class PhoneOtpService {
  PhoneOtpService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;
  static const String _basePath = '/users';

  Future<void> sendCode(String phoneNumber) async {
    try {
      final request = PhoneVerificationRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/phone/send-code',
        data: request.toJson(),
      );
      if (response.statusCode != 200) {
        throw ApiFailure(
          message: '인증번호를 전송하지 못했습니다.',
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      throw AppFailure.fromException(error);
    }
  }

  Future<bool> verifyCode(String phoneNumber, String code) async {
    try {
      final request = VerifyPhoneCodeRequest(
        phoneNumber: phoneNumber,
        code: code,
      );
      final response = await _dio.post(
        '$_basePath/phone/verify-code',
        data: request.toJson(),
      );
      return response.data['data'] == true;
    } catch (error) {
      throw AppFailure.fromException(error);
    }
  }

  Future<FindIdResponse> findIdByPhone(String phoneNumber) async {
    try {
      final request = FindIdByPhoneRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/find-id',
        data: request.toJson(),
      );

      final data = response.data['data'];
      if (response.statusCode != 200 || data == null) {
        throw ApiFailure(
          message: '아이디를 찾지 못했습니다.',
          statusCode: response.statusCode,
        );
      }
      return FindIdResponse.fromJson(data);
    } catch (error) {
      throw AppFailure.fromException(error);
    }
  }
}
