import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/login_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/response/login_response.dart';
import 'package:dio/dio.dart';

class LoginService {
  LoginService() : _dio = ApiClient.dio;
  final Dio _dio;

  static const String _basePath = '/users';

  // 이메일 로그인
  Future<LoginResponse> login(String email, String password) async {
    try {
      final request = LoginRequest(id: email, password: password);

      final response = await _dio.post(
        '$_basePath/login',
        data: request.toJson(),
      );

      return LoginResponse.fromJson(response.data['data']);
    } catch (e) {
      throw '아이디 또는 비밀번호가 올바르지 않습니다.';
    }
  }
}
