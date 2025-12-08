import 'package:boulderside_flutter/src/features/signup/application/signup_form_store.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/widgets/success_dialog.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/widgets/terms_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupFormScreen extends ConsumerStatefulWidget {
  const SignupFormScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  ConsumerState<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends ConsumerState<SignupFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _listenersAttached = false;
  bool _successHandled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(signupFormStoreProvider.notifier)
          .lookupUserByPhone(widget.phoneNumber);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _attachListeners(SignupFormStore store) {
    if (_listenersAttached) return;
    _emailController.addListener(
      () => store.updateEmail(_emailController.text),
    );
    _passwordController.addListener(
      () => store.updatePassword(_passwordController.text),
    );
    _passwordConfirmController.addListener(
      () => store.updatePasswordConfirm(_passwordConfirmController.text),
    );
    _nameController.addListener(() => store.updateName(_nameController.text));
    _listenersAttached = true;
  }

  void _syncControllers(SignupFormState state) {
    void sync(TextEditingController controller, String value) {
      if (controller.text == value) return;
      final selection = controller.selection;
      controller.text = value;
      final offset = value.length;
      controller.selection = selection.copyWith(
        baseOffset: offset,
        extentOffset: offset,
      );
    }

    sync(_emailController, state.email);
    sync(_passwordController, state.password);
    sync(_passwordConfirmController, state.passwordConfirm);
    sync(_nameController, state.name);
  }

  void _showSuccessDialog(bool isExistingUser) {
    SuccessDialog.show(context, isExistingUser);
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.read(signupFormStoreProvider.notifier);
    final state = ref.watch(signupFormStoreProvider);

    if (state.isSuccess && !_successHandled) {
      _successHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(state.isExistingUser);
      });
    }

    if (state.isLoadingLookup) {
      return Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: _buildAppBar(context, title: '회원가입'),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3278)),
          ),
        ),
      );
    }

    _attachListeners(store);
    _syncControllers(state);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: _buildAppBar(
        context,
        title: state.isExistingUser ? '계정 연동' : '회원가입',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    _buildEmailField(state, store),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Color(0xFFFF5252),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hint: '비밀번호를 입력하세요 (6자 이상)',
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _passwordConfirmController,
                      label: '비밀번호 확인',
                      hint: '비밀번호를 다시 입력하세요',
                    ),
                    const SizedBox(height: 16),
                    _buildNameField(state.isExistingUser),
                    const SizedBox(height: 16),
                    _buildGenderSelector(state, store),
                    const SizedBox(height: 16),
                    _buildTermsSection(state, store),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              color: const Color(0xFF181A20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: state.canSubmit
                      ? () => store.handleSubmit(widget.phoneNumber)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    disabledBackgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          state.isExistingUser ? '계정 연동' : '회원가입 완료',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, {
    required String title,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildEmailField(SignupFormState state, SignupFormStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                enabled: !state.emailDuplicateChecked,
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: state.emailDuplicateChecked
                      ? Colors.grey[400]
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: '아이디를 입력하세요',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    color: state.emailDuplicateChecked
                        ? Colors.grey[500]
                        : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: state.emailDuplicateChecked
                      ? Colors.grey[800]
                      : const Color.fromRGBO(130, 145, 179, 0.1333),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: state.emailDuplicateChecked
                          ? Colors.grey[700]!
                          : Colors.grey[600]!,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    state.isCheckingEmail ||
                        _emailController.text.trim().isEmpty
                    ? null
                    : store.checkEmailDuplicate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  disabledBackgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.isCheckingEmail
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '중복확인',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildNameField(bool isExistingUser) {
    return TextField(
      controller: _nameController,
      enabled: !isExistingUser,
      style: TextStyle(
        fontFamily: 'Pretendard',
        color: isExistingUser ? Colors.grey[400] : Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: '닉네임',
        labelStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: '닉네임을 입력하세요',
        hintStyle: TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.grey[600],
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildGenderSelector(SignupFormState state, SignupFormStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '성별',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderChip(
                label: '남성',
                selected: state.selectedGender == 'male',
                onTap: state.isExistingUser
                    ? null
                    : () => store.selectGender('male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderChip(
                label: '여성',
                selected: state.selectedGender == 'female',
                onTap: state.isExistingUser
                    ? null
                    : () => store.selectGender('female'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsSection(SignupFormState state, SignupFormStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이용약관',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        TermsRow(
          label: '[필수] 이용약관 동의',
          checked: state.agreeTerms1,
          onChanged: (_) => store.toggleTerms1(),
          onView: _showComingSoon,
        ),
        TermsRow(
          label: '[필수] 개인정보 처리방침 동의',
          checked: state.agreeTerms2,
          onChanged: (_) => store.toggleTerms2(),
          onView: _showComingSoon,
        ),
        TermsRow(
          label: '[필수] 만 14세 이상입니다',
          checked: state.agreeTerms3,
          onChanged: (_) => store.toggleTerms3(),
          onView: _showComingSoon,
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF3278) : const Color(0xFF262A34),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFFF3278) : Colors.grey[700]!,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: selected ? Colors.white : Colors.grey[300],
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
