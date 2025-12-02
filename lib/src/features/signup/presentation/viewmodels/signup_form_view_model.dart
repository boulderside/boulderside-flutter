import 'package:flutter/material.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/signup_form_service.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/response/phone_lookup_response.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/request/signup_request.dart';
import 'package:boulderside_flutter/src/features/signup/data/models/enums.dart';

class SignupFormViewModel extends ChangeNotifier {
  SignupFormViewModel(this._signupFormService);

  final SignupFormService _signupFormService;

  bool _isLoadingLookup = true;
  bool _isExistingUser = false;
  PhoneLookupResponse? _phoneLookupResponse;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isCheckingEmail = false;

  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  String _name = '';
  String? _selectedGender;
  bool _emailDuplicateChecked = false;
  bool _agreeTerms1 = false;
  bool _agreeTerms2 = false;
  bool _agreeTerms3 = false;

  bool get isLoadingLookup => _isLoadingLookup;
  bool get isExistingUser => _isExistingUser;
  PhoneLookupResponse? get phoneLookupResponse => _phoneLookupResponse;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get isSuccess => _isSuccess;
  bool get isCheckingEmail => _isCheckingEmail;

  String get email => _email;
  String get password => _password;
  String get passwordConfirm => _passwordConfirm;
  String get name => _name;
  String? get selectedGender => _selectedGender;
  bool get emailDuplicateChecked => _emailDuplicateChecked;
  bool get agreeTerms1 => _agreeTerms1;
  bool get agreeTerms2 => _agreeTerms2;
  bool get agreeTerms3 => _agreeTerms3;

  bool get allFieldsFilled {
    if (_isExistingUser) {
      return _email.trim().isNotEmpty &&
          _password.isNotEmpty &&
          _password == _passwordConfirm;
    }
    return _email.trim().isNotEmpty &&
        _password.isNotEmpty &&
        _passwordConfirm.isNotEmpty &&
        _name.trim().isNotEmpty &&
        _password == _passwordConfirm &&
        _selectedGender != null &&
        _emailDuplicateChecked;
  }

  bool get allTermsAgreed => _agreeTerms1 && _agreeTerms2 && _agreeTerms3;
  bool get canSubmit => allFieldsFilled && allTermsAgreed && !_isSubmitting;

  Future<void> lookupUserByPhone(String phoneNumber) async {
    _isLoadingLookup = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _signupFormService.lookupUserByPhone(phoneNumber);
      _phoneLookupResponse = response;
      _isExistingUser = response.exists;
      _isLoadingLookup = false;
      if (_isExistingUser) {
        _populateExistingUserData();
      }
      notifyListeners();
    } catch (e) {
      _isExistingUser = false;
      _isLoadingLookup = false;
      notifyListeners();
    }
  }

  void _populateExistingUserData() {
    final lookup = _phoneLookupResponse;
    if (lookup == null) return;
    if (lookup.nickname != null) {
      _name = lookup.nickname!;
    }
    if (lookup.userSex != null) {
      _selectedGender = lookup.userSex == UserSex.man ? 'male' : 'female';
    }
  }

  void updateEmail(String value) {
    if (_email == value) return;
    _email = value;
    _emailDuplicateChecked = false;
    notifyListeners();
  }

  void updatePassword(String value) {
    if (_password == value) return;
    _password = value;
    notifyListeners();
  }

  void updatePasswordConfirm(String value) {
    if (_passwordConfirm == value) return;
    _passwordConfirm = value;
    notifyListeners();
  }

  void updateName(String value) {
    if (_name == value) return;
    _name = value;
    notifyListeners();
  }

  void selectGender(String? gender) {
    if (_isExistingUser) return;
    _selectedGender = gender;
    notifyListeners();
  }

  Future<void> checkEmailDuplicate() async {
    final email = _email.trim();
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

  Future<void> handleSubmit(String phoneNumber) async {
    if (!canSubmit) return;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isExistingUser) {
        await _linkPhoneAccount();
      } else {
        await _signUp(phoneNumber);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _linkPhoneAccount() async {
    try {
      await _signupFormService.linkPhoneAccount(
        _phoneLookupResponse!.phone!,
        _email.trim(),
        _password,
      );
      _isSubmitting = false;
      _isSuccess = true;
      notifyListeners();
    } catch (e) {
      throw Exception('계정 연동 실패: $e');
    }
  }

  Future<void> _signUp(String phoneNumber) async {
    try {
      final signupRequest = SignupRequest(
        nickname: _name.trim(),
        email: _email.trim(),
        password: _password,
        name: _name.trim(),
        phone: phoneNumber,
        userSex: _selectedGender == 'male' ? UserSex.man : UserSex.woman,
        userRole: UserRole.roleUser,
        userLevel: Level.v0,
      );

      await _signupFormService.signUp(signupRequest);
      _isSubmitting = false;
      _isSuccess = true;
      notifyListeners();
    } catch (e) {
      throw Exception('회원가입 실패: $e');
    }
  }

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
    _email = '';
    _password = '';
    _passwordConfirm = '';
    _name = '';
    notifyListeners();
  }
}
