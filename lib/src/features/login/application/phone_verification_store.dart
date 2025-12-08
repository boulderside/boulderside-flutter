import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/app_failure.dart';
import 'package:boulderside_flutter/src/features/auth/data/services/phone_otp_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhoneVerificationStore extends StateNotifier<PhoneVerificationState> {
  PhoneVerificationStore(this._phoneOtpService)
    : super(const PhoneVerificationState());

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
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> findIdByPhone(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: '전화번호를 입력해주세요.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      phoneNumber: phoneNumber,
      foundEmail: null,
    );

    try {
      final response = await _phoneOtpService.findIdByPhone(phoneNumber);
      state = state.copyWith(isLoading: false, foundEmail: response.email);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppFailure.fromException(e).message,
      );
    }
  }

  void resetTransientState() {
    state = state.copyWith(
      isCodeVerified: false,
      errorMessage: null,
      foundEmail: null,
    );
  }
}

const _sentinel = Object();

class PhoneVerificationState {
  const PhoneVerificationState({
    this.isCodeSent = false,
    this.isCodeVerified = false,
    this.isLoading = false,
    this.errorMessage,
    this.phoneNumber = '',
    this.foundEmail,
  });

  final bool isCodeSent;
  final bool isCodeVerified;
  final bool isLoading;
  final String? errorMessage;
  final String phoneNumber;
  final String? foundEmail;

  PhoneVerificationState copyWith({
    bool? isCodeSent,
    bool? isCodeVerified,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    String? phoneNumber,
    Object? foundEmail = _sentinel,
  }) {
    return PhoneVerificationState(
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isCodeVerified: isCodeVerified ?? this.isCodeVerified,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      foundEmail: identical(foundEmail, _sentinel)
          ? this.foundEmail
          : foundEmail as String?,
    );
  }
}

final phoneVerificationStoreProvider =
    StateNotifierProvider<PhoneVerificationStore, PhoneVerificationState>((
      ref,
    ) {
      final service = di<PhoneOtpService>();
      return PhoneVerificationStore(service);
    });
