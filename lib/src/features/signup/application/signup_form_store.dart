import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/enums.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/signup_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/response/phone_lookup_response.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/signup_form_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupFormStore extends StateNotifier<SignupFormState> {
  SignupFormStore(this._service) : super(const SignupFormState());

  final SignupFormService _service;

  Future<void> lookupUserByPhone(String phoneNumber) async {
    state = state.copyWith(isLoadingLookup: true, errorMessage: null);
    try {
      final response = await _service.lookupUserByPhone(phoneNumber);
      state = state.copyWith(
        isLoadingLookup: false,
        phoneLookupResponse: response,
        isExistingUser: response.exists,
      );
      if (response.exists) {
        _populateExistingUserData(response);
      }
    } catch (_) {
      // 전화번호 조회 실패는 신규 회원 시나리오로 간주
      state = state.copyWith(
        isLoadingLookup: false,
        isExistingUser: false,
        phoneLookupResponse: null,
        errorMessage: null,
      );
    }
  }

  void _populateExistingUserData(PhoneLookupResponse lookup) {
    final String? gender = lookup.userSex == null
        ? state.selectedGender
        : lookup.userSex == UserSex.man
        ? 'male'
        : 'female';
    state = state.copyWith(
      name: lookup.nickname ?? state.name,
      selectedGender: gender,
    );
  }

  void updateEmail(String value) {
    if (state.email == value) return;
    state = state.copyWith(email: value, emailDuplicateChecked: false);
  }

  void updatePassword(String value) {
    if (state.password == value) return;
    state = state.copyWith(password: value);
  }

  void updatePasswordConfirm(String value) {
    if (state.passwordConfirm == value) return;
    state = state.copyWith(passwordConfirm: value);
  }

  void updateName(String value) {
    if (state.name == value) return;
    state = state.copyWith(name: value);
  }

  void selectGender(String? gender) {
    if (state.isExistingUser) return;
    state = state.copyWith(selectedGender: gender);
  }

  Future<void> checkEmailDuplicate() async {
    final email = state.email.trim();
    if (email.isEmpty) return;

    state = state.copyWith(isCheckingEmail: true, errorMessage: null);

    try {
      final isAvailable = await _service.checkUserId(email);
      state = state.copyWith(
        emailDuplicateChecked: isAvailable,
        errorMessage: isAvailable ? null : '이미 사용 중인 아이디입니다.',
      );
    } catch (error) {
      state = state.copyWith(
        emailDuplicateChecked: false,
        errorMessage: error.toString(),
      );
    } finally {
      state = state.copyWith(isCheckingEmail: false);
    }
  }

  void toggleTerms1() {
    state = state.copyWith(agreeTerms1: !state.agreeTerms1);
  }

  void toggleTerms2() {
    state = state.copyWith(agreeTerms2: !state.agreeTerms2);
  }

  void toggleTerms3() {
    state = state.copyWith(agreeTerms3: !state.agreeTerms3);
  }

  Future<void> handleSubmit(String phoneNumber) async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      if (state.isExistingUser) {
        await _linkPhoneAccount();
      } else {
        await _signUp(phoneNumber);
      }
      state = state.copyWith(isSuccess: true);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> _linkPhoneAccount() async {
    final lookup = state.phoneLookupResponse;
    if (lookup?.phone == null) {
      throw Exception('휴대폰 인증 정보가 없습니다.');
    }
    try {
      await _service.linkPhoneAccount(
        lookup!.phone!,
        state.email.trim(),
        state.password,
      );
    } catch (error) {
      throw Exception('계정 연동 실패: $error');
    }
  }

  Future<void> _signUp(String phoneNumber) async {
    try {
      final signupRequest = SignupRequest(
        nickname: state.name.trim(),
        email: state.email.trim(),
        password: state.password,
        name: state.name.trim(),
        phoneNumber: phoneNumber,
        userSex: state.selectedGender == 'male' ? UserSex.man : UserSex.woman,
        userRole: UserRole.roleUser,
        userLevel: Level.v0,
      );
      await _service.signUp(signupRequest);
    } catch (error) {
      throw Exception('회원가입 실패: $error');
    }
  }

  void reset() {
    state = const SignupFormState();
  }
}

const _sentinel = Object();

class SignupFormState {
  const SignupFormState({
    this.isLoadingLookup = true,
    this.isExistingUser = false,
    this.phoneLookupResponse,
    this.errorMessage,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isCheckingEmail = false,
    this.email = '',
    this.password = '',
    this.passwordConfirm = '',
    this.name = '',
    this.selectedGender,
    this.emailDuplicateChecked = false,
    this.agreeTerms1 = false,
    this.agreeTerms2 = false,
    this.agreeTerms3 = false,
  });

  final bool isLoadingLookup;
  final bool isExistingUser;
  final PhoneLookupResponse? phoneLookupResponse;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isCheckingEmail;
  final String email;
  final String password;
  final String passwordConfirm;
  final String name;
  final String? selectedGender;
  final bool emailDuplicateChecked;
  final bool agreeTerms1;
  final bool agreeTerms2;
  final bool agreeTerms3;

  bool get allFieldsFilled {
    if (isExistingUser) {
      return email.trim().isNotEmpty &&
          password.isNotEmpty &&
          password == passwordConfirm;
    }
    return email.trim().isNotEmpty &&
        password.isNotEmpty &&
        passwordConfirm.isNotEmpty &&
        name.trim().isNotEmpty &&
        password == passwordConfirm &&
        selectedGender != null &&
        emailDuplicateChecked;
  }

  bool get allTermsAgreed => agreeTerms1 && agreeTerms2 && agreeTerms3;

  bool get canSubmit => allFieldsFilled && allTermsAgreed && !isSubmitting;

  SignupFormState copyWith({
    bool? isLoadingLookup,
    bool? isExistingUser,
    Object? phoneLookupResponse = _sentinel,
    Object? errorMessage = _sentinel,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isCheckingEmail,
    String? email,
    String? password,
    String? passwordConfirm,
    String? name,
    Object? selectedGender = _sentinel,
    bool? emailDuplicateChecked,
    bool? agreeTerms1,
    bool? agreeTerms2,
    bool? agreeTerms3,
  }) {
    return SignupFormState(
      isLoadingLookup: isLoadingLookup ?? this.isLoadingLookup,
      isExistingUser: isExistingUser ?? this.isExistingUser,
      phoneLookupResponse: identical(phoneLookupResponse, _sentinel)
          ? this.phoneLookupResponse
          : phoneLookupResponse as PhoneLookupResponse?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isCheckingEmail: isCheckingEmail ?? this.isCheckingEmail,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      name: name ?? this.name,
      selectedGender: identical(selectedGender, _sentinel)
          ? this.selectedGender
          : selectedGender as String?,
      emailDuplicateChecked:
          emailDuplicateChecked ?? this.emailDuplicateChecked,
      agreeTerms1: agreeTerms1 ?? this.agreeTerms1,
      agreeTerms2: agreeTerms2 ?? this.agreeTerms2,
      agreeTerms3: agreeTerms3 ?? this.agreeTerms3,
    );
  }
}

final signupFormServiceProvider = Provider<SignupFormService>((ref) {
  return di<SignupFormService>();
});

final signupFormStoreProvider =
    StateNotifierProvider.autoDispose<SignupFormStore, SignupFormState>((ref) {
      final service = ref.watch(signupFormServiceProvider);
      return SignupFormStore(service);
    });
