import 'package:dio/dio.dart';

import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/oauth_signup_request.dart';
import 'package:boulderside_flutter/src/features/login/data/models/response/oauth_login_response.dart';

class OAuthSignupService {
  OAuthSignupService() : _dio = ApiClient.dio;

  final Dio _dio;

  static const String _basePath = '/auth/oauth/signup';

  Future<OAuthLoginResponse> signup(OAuthSignupRequest request) async {
    final response = await _dio.post(_basePath, data: request.toJson());
    final data = response.data['data'] as Map<String, dynamic>;
    return OAuthLoginResponse.fromJson(data);
  }
}
