import 'package:boulderside_flutter/login/models/login_response.dart';
import 'package:dio/dio.dart';

class AuthService {
  final dio = Dio();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 이메일 로그인
  Future<LoginResponse> signInWithEmail(String email, String password) async {
    try {
      // final response = await dio.post(
      //   '/api/users/login',
      //   data: {'id': email, 'password': password},
      // );

      // 더미 데이터 제공하기
      await Future.delayed(const Duration(seconds: 1));

      final dummyJson = {
        'email': 'boulderside@gmail.com',
        'accessToken': '123456789@',
        'refreshToken': '123456789**',
      };

      return LoginResponse.fromJson(dummyJson);
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }

  // 네이버 로그인
  Future<bool> signInWithNaver() async {
    try {
      // TODO: 네이버 로그인 구현
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      return true;
    } catch (e) {
      print('네이버 로그인 실패: $e');
      return false;
    }
  }

  // 카카오 로그인
  Future<bool> signInWithKakao() async {
    try {
      // TODO: 카카오 로그인 구현
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      return true;
    } catch (e) {
      print('카카오 로그인 실패: $e');
      return false;
    }
  }

  // 애플 로그인
  Future<bool> signInWithApple() async {
    try {
      // TODO: 애플 로그인 구현
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      return true;
    } catch (e) {
      print('애플 로그인 실패: $e');
      return false;
    }
  }

  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      // TODO: 구글 로그인 구현
      await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이
      return true;
    } catch (e) {
      print('구글 로그인 실패: $e');
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // TODO: 로그아웃 구현
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }

  // 현재 사용자 상태 확인
  bool get isLoggedIn {
    // TODO: 실제 로그인 상태 확인 로직 구현
    return false;
  }
}
