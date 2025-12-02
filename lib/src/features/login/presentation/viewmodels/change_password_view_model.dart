import 'package:boulderside_flutter/src/features/login/data/services/change_password_service.dart';
import 'package:flutter/foundation.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordService _changePasswordService;

  ChangePasswordViewModel(this._changePasswordService);

  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordChanged = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordChanged => _isPasswordChanged;

  // 비밀번호 변경
  Future<void> changePassword(String phoneNumber, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _isPasswordChanged = false;
    notifyListeners();

    try {
      await _changePasswordService.changePassword(phoneNumber, newPassword);
      _isPasswordChanged = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 상태 초기화
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isPasswordChanged = false;
    notifyListeners();
  }
}
