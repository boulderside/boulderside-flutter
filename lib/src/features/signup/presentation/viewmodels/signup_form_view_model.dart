import 'package:flutter/material.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/signup_form_service.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/response/phone_lookup_response.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/signup_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/enums.dart';

class SignupFormViewModel extends ChangeNotifier {
  final SignupFormService _signupFormService;

  SignupFormViewModel(this._signupFormService);

  // 상태 변수들
  bool _isLoadingLookup = true;
  bool _isExistingUser = false;
  PhoneLookupResponse? _phoneLookupResponse;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isCheckingEmail = false;

  // 폼 관련 상태
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedGender;
  bool _emailDuplicateChecked = false;
  bool _agreeTerms1 = false;
  bool _agreeTerms2 = false;
  bool _agreeTerms3 = false;

  // Getters
  bool get isLoadingLookup => _isLoadingLookup;
  bool get isExistingUser => _isExistingUser;
  PhoneLookupResponse? get phoneLookupResponse => _phoneLookupResponse;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isSuccess => _isSuccess;
  bool get isCheckingEmail => _isCheckingEmail;

  // 폼 관련 Getters
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get passwordConfirmController =>
      _passwordConfirmController;
  TextEditingController get nameController => _nameController;
  String? get selectedGender => _selectedGender;
  bool get emailDuplicateChecked => _emailDuplicateChecked;
  bool get agreeTerms1 => _agreeTerms1;
  bool get agreeTerms2 => _agreeTerms2;
  bool get agreeTerms3 => _agreeTerms3;

  // 폼 유효성 검사
  bool get allFieldsFilled {
    if (_isExistingUser) {
      // 기존 사용자 (연동): 이메일, 비밀번호만 필요
      return _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _passwordConfirmController.text;
    } else {
      // 신규 사용자 (회원가입): 모든 필드 필요
      return _emailController.text.trim().isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _passwordConfirmController.text.isNotEmpty &&
          _nameController.text.trim().isNotEmpty &&
          _passwordController.text == _passwordConfirmController.text &&
          _selectedGender != null &&
          _emailDuplicateChecked;
    }
  }

  bool get allTermsAgreed => _agreeTerms1 && _agreeTerms2 && _agreeTerms3;
  bool get canSubmit => allFieldsFilled && allTermsAgreed && !_isSubmitting;

  // 전화번호로 사용자 조회
  Future<void> lookupUserByPhone(String phoneNumber) async {
    _isLoadingLookup = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _signupFormService.lookupUserByPhone(phoneNumber);

      _phoneLookupResponse = response;
      _isExistingUser = response.exists;
      _isLoadingLookup = false;

      // 기존 사용자인 경우 UI 자동 채우기
      if (_isExistingUser) {
        _populateExistingUserData();
      }

      notifyListeners();
    } catch (e) {
      _isExistingUser = false;
      _isLoadingLookup = false;
      // 에러 메시지를 화면에 표시하지 않음 (조용히 신규 사용자로 처리)
      notifyListeners();
    }
  }

  // 기존 사용자 데이터로 UI 자동 채우기
  void _populateExistingUserData() {
    if (_phoneLookupResponse != null) {
      // 닉네임 자동 채우기
      if (_phoneLookupResponse!.nickname != null) {
        _nameController.text = _phoneLookupResponse!.nickname!;
      }

      // 성별 자동 선택
      if (_phoneLookupResponse!.userSex != null) {
        _selectedGender = _phoneLookupResponse!.userSex == UserSex.man
            ? 'male'
            : 'female';
      }
    }
  }

  // 폼 필드 변경 핸들러
  void onFieldChanged() {
    notifyListeners();
  }

  // 성별 선택
  void selectGender(String? gender) {
    if (!_isExistingUser) {
      _selectedGender = gender;
      notifyListeners();
    }
  }

  // 이메일 중복 확인
  Future<void> checkEmailDuplicate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    _isCheckingEmail = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isAvailable = await _signupFormService.checkUserId(email);

      if (isAvailable) {
        _emailDuplicateChecked = true;
        _errorMessage = null;
      } else {
        _emailDuplicateChecked = false;
        _errorMessage = '이미 사용 중인 아이디입니다.';
      }
    } catch (e) {
      _emailDuplicateChecked = false;
      _errorMessage = e.toString();
    } finally {
      _isCheckingEmail = false;
      notifyListeners();
    }
  }

  // 약관 동의 토글
  void toggleTerms1() {
    _agreeTerms1 = !_agreeTerms1;
    notifyListeners();
  }

  void toggleTerms2() {
    _agreeTerms2 = !_agreeTerms2;
    notifyListeners();
  }

  void toggleTerms3() {
    _agreeTerms3 = !_agreeTerms3;
    notifyListeners();
  }

  // 폼 제출
  Future<void> handleSubmit(String phoneNumber) async {
    if (!canSubmit) return;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isExistingUser) {
        // 기존 사용자 - 계정 연동
        await _linkPhoneAccount();
      } else {
        // 신규 사용자 - 회원가입
        await _signUp(phoneNumber);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // 계정 연동
  Future<void> _linkPhoneAccount() async {
    try {
      await _signupFormService.linkPhoneAccount(
        _phoneLookupResponse!.phone!,
        _emailController.text.trim(),
        _passwordController.text,
      );
      // 성공 시 처리
      _isSubmitting = false;
      _isSuccess = true;
      notifyListeners();
    } catch (e) {
      throw Exception('계정 연동 실패: $e');
    }
  }

  // 회원가입
  Future<void> _signUp(String phoneNumber) async {
    try {
      // SignupRequest 생성
      final signupRequest = SignupRequest(
        nickname: _nameController.text.trim(), // nickname은 필수
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: phoneNumber, // widget.phoneNumber 사용
        userSex: _selectedGender == 'male' ? UserSex.man : UserSex.woman,
        userRole: UserRole.roleUser, // 기본값
        userLevel: Level.v0, // 기본값
      );

      await _signupFormService.signUp(signupRequest);
      _isSubmitting = false;
      _isSuccess = true;
      notifyListeners();
    } catch (e) {
      throw Exception('회원가입 실패: $e');
    }
  }

  // 상태 초기화
  void reset() {
    _isLoadingLookup = true;
    _isExistingUser = false;
    _phoneLookupResponse = null;
    _errorMessage = null;
    _isSubmitting = false;
    _selectedGender = null;
    _emailDuplicateChecked = false;
    _agreeTerms1 = false;
    _agreeTerms2 = false;
    _agreeTerms3 = false;

    _emailController.clear();
    _passwordController.clear();
    _passwordConfirmController.clear();
    _nameController.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
