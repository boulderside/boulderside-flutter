import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/features/auth/data/services/phone_otp_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneAuthStore extends StateNotifier<PhoneAuthState> {
  PhoneAuthStore(this._phoneOtpService) : super(const PhoneAuthState());

  final PhoneOtpService _phoneOtpService;

  Future<void> sendVerificationCode(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: '전화번호를 입력해주세요.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      phoneNumber: phoneNumber,
      isCodeVerified: false,
    );

    try {
      await _phoneOtpService.sendCode(phoneNumber);
      state = state.copyWith(
        isLoading: false,
        isCodeSent: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppFailure.fromException(e).message,
      );
    }
  }

  Future<void> verifyCode(String phoneNumber, String verificationCode) async {
    if (verificationCode.isEmpty) {
      state = state.copyWith(errorMessage: '인증번호를 입력해주세요.');
      return;
    }
    if (phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: '전화번호를 입력해주세요.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      phoneNumber: phoneNumber,
    );

    try {
      final isVerified = await _phoneOtpService.verifyCode(
        phoneNumber,
        verificationCode,
      );
      if (isVerified) {
        state = state.copyWith(
          isLoading: false,
          isCodeVerified: true,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '인증번호가 일치하지 않습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppFailure.fromException(e).message,
      );
    }
  }

  void reset() {
    state = state.copyWith(isCodeVerified: false, errorMessage: null);
  }
}

const _sentinel = Object();

class PhoneAuthState {
  const PhoneAuthState({
    this.isCodeSent = false,
    this.isCodeVerified = false,
    this.isLoading = false,
    this.errorMessage,
    this.phoneNumber = '',
  });

  final bool isCodeSent;
  final bool isCodeVerified;
  final bool isLoading;
  final String? errorMessage;
  final String phoneNumber;

  PhoneAuthState copyWith({
    bool? isCodeSent,
    bool? isCodeVerified,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    String? phoneNumber,
  }) {
    return PhoneAuthState(
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

final phoneAuthStoreProvider =
    StateNotifierProvider.autoDispose<PhoneAuthStore, PhoneAuthState>((ref) {
      final service = di<PhoneOtpService>();
      return PhoneAuthStore(service);
    });
