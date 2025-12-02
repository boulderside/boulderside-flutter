import 'dart:async';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/features/auth/data/services/phone_otp_service.dart';
import 'package:flutter/foundation.dart';

class PhoneVerificationViewModel extends ChangeNotifier {
  final PhoneOtpService _phoneOtpService;

  PhoneVerificationViewModel(this._phoneOtpService);

  // 상태 변수들
  bool _isCodeSent = false;
  bool _isCodeVerified = false; // 해당 값이 true면, 인증번호 검증 성공
  bool _isLoading = false;
  String? _errorMessage;
  String _phoneNumber = '';
  String? _foundEmail;

  // Getters
  bool get isCodeSent => _isCodeSent;
  bool get isCodeVerified => _isCodeVerified;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get phoneNumber => _phoneNumber;
  String? get foundEmail => _foundEmail;

  // 인증번호 전송/재전송
  Future<void> sendVerificationCode(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _errorMessage = '전화번호를 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    _isCodeVerified = false; // 재전송 시 인증 상태 초기화
    notifyListeners();

    try {
      await _phoneOtpService.sendCode(phoneNumber);
      _isCodeSent = true;
    } catch (e) {
      _errorMessage = AppFailure.fromException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 인증번호 검증
  Future<void> verifyCode(String phoneNumber, String verificationCode) async {
    if (verificationCode.isEmpty) {
      _errorMessage = '인증번호를 입력해주세요.';
      notifyListeners();
      return;
    }

    if (phoneNumber.isEmpty) {
      _errorMessage = '전화번호를 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      final isVerified = await _phoneOtpService.verifyCode(
        phoneNumber,
        verificationCode,
      );

      if (isVerified) {
        _isCodeVerified = true;
      } else {
        _errorMessage = '인증번호가 일치하지 않습니다.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 아이디 찾기
  Future<void> findIdByPhone(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _errorMessage = '전화번호를 입력해주세요.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    _foundEmail = null;
    notifyListeners();

    try {
      final response = await _phoneOtpService.findIdByPhone(phoneNumber);
      _foundEmail = response.email;
    } catch (e) {
      _errorMessage = AppFailure.fromException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 상태 초기화
  void reset() {
    //_isCodeSent = false;
    _isCodeVerified = false;
    _isLoading = false;
    _errorMessage = null;
    //_phoneNumber = '';
    _foundEmail = null;
    notifyListeners();
  }
}
