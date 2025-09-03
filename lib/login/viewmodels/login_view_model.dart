import 'dart:async';
import 'package:boulderside_flutter/login/services/login_service.dart';
import 'package:boulderside_flutter/login/models/response/login_response.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService;

  LoginViewModel(this._loginService);

  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  // 로그인
  Future<void> login(String email, String password) async {
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
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 로그인 상태 초기화
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();
  }
}
