import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/features/login/domain/usecases/login_with_email_use_case.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._loginWithEmailUseCase);

  final LoginWithEmailUseCase _loginWithEmailUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAutoLoginEnabled = true;
  User? _authenticatedUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAutoLoginEnabled => _isAutoLoginEnabled;
  bool get loginSucceeded => _authenticatedUser != null;

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
    _authenticatedUser = null;
    notifyListeners();

    final Result<User> result = await _loginWithEmailUseCase(
      email: email,
      password: password,
      autoLogin: _isAutoLoginEnabled,
    );

    result.when(
      success: (user) => _authenticatedUser = user,
      failure: (failure) => _errorMessage = failure.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  void toggleAutoLogin(bool value) {
    _isAutoLoginEnabled = value;
    notifyListeners();
  }

  void consumeSuccess() {
    _authenticatedUser = null;
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _authenticatedUser = null;
    notifyListeners();
  }
}
