import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/phone_lookup_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/phone_link_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/signup_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/response/phone_lookup_response.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class SignupFormService {
  SignupFormService() : _dio = ApiClient.dio;
  final Dio _dio;

  static const String _basePath = '/users';

  // 아이디 중복 확인
  Future<bool> checkUserId(String username) async {
    try {
      final response = await _dio.get(
        '$_basePath/check-id',
        queryParameters: {'username': username},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to check user id');
      }

      // API 응답에서 사용 가능 여부 반환 (true: 사용 가능, false: 중복)
      return response.data['data'] as bool;
    } catch (e) {
      throw Exception('아이디 중복 확인 실패: $e');
    }
  }

  // 전화번호로 사용자 조회
  Future<PhoneLookupResponse> lookupUserByPhone(String phoneNumber) async {
    try {
      final request = PhoneLookupRequest(phoneNumber: phoneNumber);
      final response = await _dio.post(
        '$_basePath/phone/lookup',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to lookup user by phone');
      }

      return PhoneLookupResponse.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('전화번호로 사용자 조회 실패: $e');
    }
  }

  // 전화번호로 계정 연결
  Future<void> linkPhoneAccount(
    String phoneNumber,
    String email,
    String password,
  ) async {
    try {
      final request = PhoneLinkRequest(
        phoneNumber: phoneNumber,
        email: email,
        password: password,
      );
      final response = await _dio.post(
        '$_basePath/phone/link-account',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to link phone account');
      }
    } catch (e) {
      throw Exception('전화번호 계정 연결 실패: $e');
    }
  }

  // 회원가입 (multipart file 지원)
  Future<void> signUp(SignupRequest request, {File? profileImage}) async {
    try {
      final formData = FormData.fromMap({
        'data': MultipartFile.fromString(
          jsonEncode(request.toJson()), // JSON을 문자열로 변환
          contentType: MediaType('application', 'json'), // Content-Type 명시
        ),
        if (profileImage != null)
          'file': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        '$_basePath/sign-up',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      throw Exception('회원가입 실패: $e');
    }
  }
}
