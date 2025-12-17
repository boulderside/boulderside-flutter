import 'package:boulderside_flutter/src/core/user/data/services/nickname_service.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/oauth_signup_payload.dart';
import 'package:boulderside_flutter/src/features/login/providers/login_providers.dart';
import 'package:boulderside_flutter/src/shared/utils/random_nickname_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupState {
  const SignupState({
    required this.nickname,
    this.isAgeVerified = false,
    this.isServiceTermsAccepted = false,
    this.isPrivacyPolicyAccepted = false,
    this.isMarketingConsentAccepted = false,
    this.isAvailable = false,
    this.isChecking = false,
    this.statusMessage,
    this.statusColor,
  });

  final String nickname;
  final bool isAgeVerified;
  final bool isServiceTermsAccepted;
  final bool isPrivacyPolicyAccepted;
  final bool isMarketingConsentAccepted;
  final bool isAvailable;
  final bool isChecking;
  final String? statusMessage;
  final Color? statusColor;

  bool get isAllRequiredTermsAccepted =>
      isAgeVerified && isServiceTermsAccepted && isPrivacyPolicyAccepted;

  bool get isAllTermsAccepted =>
      isAgeVerified &&
      isServiceTermsAccepted &&
      isPrivacyPolicyAccepted &&
      isMarketingConsentAccepted;

  SignupState copyWith({
    String? nickname,
    bool? isAgeVerified,
    bool? isServiceTermsAccepted,
    bool? isPrivacyPolicyAccepted,
    bool? isMarketingConsentAccepted,
    bool? isAvailable,
    bool? isChecking,
    String? statusMessage,
    Color? statusColor,
    bool clearStatusMessage = false,
  }) {
    return SignupState(
      nickname: nickname ?? this.nickname,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
      isServiceTermsAccepted:
          isServiceTermsAccepted ?? this.isServiceTermsAccepted,
      isPrivacyPolicyAccepted:
          isPrivacyPolicyAccepted ?? this.isPrivacyPolicyAccepted,
      isMarketingConsentAccepted:
          isMarketingConsentAccepted ?? this.isMarketingConsentAccepted,
      isAvailable: isAvailable ?? this.isAvailable,
      isChecking: isChecking ?? this.isChecking,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
      statusColor: clearStatusMessage
          ? null
          : (statusColor ?? this.statusColor),
    );
  }
}

class SignupViewModel extends StateNotifier<SignupState> {
  SignupViewModel(
    this._nicknameService,
    this._authRepository,
    this._signupPayload,
  ) : super(SignupState(nickname: RandomNicknameGenerator.generate()));

  final NicknameService _nicknameService;
  final AuthRepository _authRepository;
  final OAuthSignupPayload? _signupPayload;

  void setNickname(String value) {
    if (state.nickname == value) return;
    state = state.copyWith(
      nickname: value,
      isAvailable: false,
      clearStatusMessage: true,
    );
  }

  void generateRandomNickname() {
    final newNickname = RandomNicknameGenerator.generate();
    state = state.copyWith(
      nickname: newNickname,
      isAvailable: false,
      clearStatusMessage: true,
    );
  }

  void toggleAllTerms(bool? value) {
    final isAccepted = value ?? false;
    state = state.copyWith(
      isAgeVerified: isAccepted,
      isServiceTermsAccepted: isAccepted,
      isPrivacyPolicyAccepted: isAccepted,
      isMarketingConsentAccepted: isAccepted,
    );
  }

  void toggleAgeVerification(bool? value) {
    state = state.copyWith(isAgeVerified: value ?? false);
  }

  void toggleServiceTerms(bool? value) {
    state = state.copyWith(isServiceTermsAccepted: value ?? false);
  }

  void togglePrivacyPolicy(bool? value) {
    state = state.copyWith(isPrivacyPolicyAccepted: value ?? false);
  }

  void toggleMarketingConsent(bool? value) {
    state = state.copyWith(isMarketingConsentAccepted: value ?? false);
  }

  Future<void> checkAvailability() async {
    final nickname = state.nickname.trim();
    if (nickname.isEmpty) {
      state = state.copyWith(
        statusMessage: '닉네임을 입력해주세요.',
        statusColor: Colors.redAccent,
        isAvailable: false,
      );
      return;
    }

    state = state.copyWith(isChecking: true, clearStatusMessage: true);

    try {
      final available = await _nicknameService.checkNicknameAvailability(
        nickname,
      );
      if (available) {
        state = state.copyWith(
          isChecking: false,
          isAvailable: true,
          statusMessage: '사용 가능한 닉네임입니다.',
          statusColor: Colors.greenAccent,
        );
      } else {
        state = state.copyWith(
          isChecking: false,
          isAvailable: false,
          statusMessage: '이미 사용 중인 닉네임입니다.',
          statusColor: Colors.redAccent,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        isAvailable: false,
        statusMessage: '확인 중 오류가 발생했습니다.',
        statusColor: Colors.redAccent,
      );
    }
  }

  Future<bool> completeSignup() async {
    if (!state.isAllRequiredTermsAccepted || !state.isAvailable) return false;

    final payload = _signupPayload;
    if (payload == null) {
      return false;
    }

    final nickname = state.nickname.trim();
    try {
      await _authRepository.signupWithOAuth(
        providerType: payload.providerType,
        identityToken: payload.identityToken,
        nickname: nickname,
        privacyAgreed: state.isPrivacyPolicyAccepted,
        serviceTermsAgreed: state.isServiceTermsAccepted,
        overFourteenAgreed: state.isAgeVerified,
        marketingAgreed: state.isMarketingConsentAccepted,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final signupViewModelProvider = StateNotifierProvider.autoDispose
    .family<SignupViewModel, SignupState, OAuthSignupPayload?>((ref, payload) {
      return SignupViewModel(
        ref.watch(nicknameServiceProvider),
        ref.watch(authRepositoryProvider),
        payload,
      );
    });
