import 'dart:async';
import 'package:boulderside_flutter/login/services/login_service.dart';
import 'package:boulderside_flutter/login/models/response/login_response.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:boulderside_flutter/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/core/user/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService;

  LoginViewModel(this._loginService);

  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;
  bool _isAutoLoginEnabled = true; // 자동 로그인 체크박스 상태 (기본값: true)

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;
  bool get isAutoLoginEnabled => _isAutoLoginEnabled;

  // 로그인
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    final userStore = context.read<UserStore>();
    if (email.isEmpty) {
      _errorMessage = '이메일을 입력해주세요.';
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      _errorMessage = '비밀번호를 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loginResponse = await _loginService.login(email, password);

      //로그인 성공 시 토큰 저장
      if (_loginResponse != null) {
        await TokenStore.saveTokens(
          _loginResponse!.accessToken,
          _loginResponse!.refreshToken,
          _isAutoLoginEnabled, // 체크박스 상태에 따라 자동 로그인 설정
        );

        // 사용자 정보를 UserStore에 저장
        final user = User(
          email: _loginResponse!.email,
          nickname: _loginResponse!.nickname,
          profileImageUrl:
              null, // LoginResponse에 profileImageUrl이 없으므로 null로 설정
        );
        await userStore.saveUser(user);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 자동 로그인 체크박스 상태 변경
  void toggleAutoLogin(bool value) {
    _isAutoLoginEnabled = value;
    notifyListeners();
  }

  // 로그인 상태 초기화
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();
  }
}
