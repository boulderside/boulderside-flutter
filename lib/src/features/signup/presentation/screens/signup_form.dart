import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/widgets/terms_row.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/widgets/success_dialog.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/viewmodels/signup_form_view_model.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/signup_form_service.dart';

class SignupFormScreen extends StatefulWidget {
  final String phoneNumber;

  const SignupFormScreen({super.key, required this.phoneNumber});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _listenersAttached = false;

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('준비 중입니다.')));
  }

  void _showSuccessDialog(BuildContext context, bool isExistingUser) {
    SuccessDialog.show(context, isExistingUser);
  }

  void _attachListeners(SignupFormViewModel viewModel) {
    if (_listenersAttached) return;
    _emailController.addListener(
      () => viewModel.updateEmail(_emailController.text),
    );
    _passwordController.addListener(
      () => viewModel.updatePassword(_passwordController.text),
    );
    _passwordConfirmController.addListener(
      () => viewModel.updatePasswordConfirm(_passwordConfirmController.text),
    );
    _nameController.addListener(
      () => viewModel.updateName(_nameController.text),
    );
    _listenersAttached = true;
  }

  void _syncControllers(SignupFormViewModel viewModel) {
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

    sync(_emailController, viewModel.email);
    sync(_passwordController, viewModel.password);
    sync(_passwordConfirmController, viewModel.passwordConfirm);
    sync(_nameController, viewModel.name);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = SignupFormViewModel(
          context.read<SignupFormService>(),
        );
        viewModel.lookupUserByPhone(widget.phoneNumber);
        return viewModel;
      },
      child: Consumer<SignupFormViewModel>(
        builder: (context, viewModel, child) {
          // 성공 시 다이얼로그 표시 및 로그인 화면으로 이동
          if (viewModel.isSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSuccessDialog(context, viewModel.isExistingUser);
            });
          }

          // 로딩 중일 때 표시
          if (viewModel.isLoadingLookup) {
            return Scaffold(
              backgroundColor: const Color(0xFF181A20),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: const Text(
                  '회원가입',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3278)),
                ),
              ),
            );
          }

          _attachListeners(viewModel);
          _syncControllers(viewModel);

          return Scaffold(
            backgroundColor: const Color(0xFF181A20),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: Text(
                viewModel.isExistingUser ? '계정 연동' : '회원가입',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 스크롤 가능한 내용
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // 입력 필드를 먼저 배치하도록 순서 조정 (프로필 이미지는 아래로 이동)
                          const SizedBox(height: 12),

                          // 이메일
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _emailController,
                                      enabled: !viewModel.emailDuplicateChecked,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: viewModel.emailDuplicateChecked
                                            ? Colors.grey[400]
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '아이디를 입력하세요',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Pretendard',
                                          color: viewModel.emailDuplicateChecked
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        filled: true,
                                        fillColor:
                                            viewModel.emailDuplicateChecked
                                            ? Colors.grey[800]
                                            : const Color.fromRGBO(
                                                130,
                                                145,
                                                179,
                                                0.1333,
                                              ),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color:
                                                viewModel.emailDuplicateChecked
                                                ? Colors.grey[700]!
                                                : Colors.grey[600]!,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey[700]!,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: viewModel.isCheckingEmail
                                          ? null
                                          : _emailController.text
                                                .trim()
                                                .isNotEmpty
                                          ? () async => await viewModel
                                                .checkEmailDuplicate()
                                          : null,
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.resolveWith(
                                          (states) {
                                            if (states.contains(
                                              WidgetState.disabled,
                                            )) {
                                              return Colors.grey[700];
                                            }
                                            return const Color(0xFFFF3278);
                                          },
                                        ),
                                        foregroundColor:
                                            const WidgetStatePropertyAll<Color>(
                                              Colors.white,
                                            ),
                                        shape:
                                            WidgetStatePropertyAll<
                                              RoundedRectangleBorder
                                            >(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                        elevation:
                                            const WidgetStatePropertyAll<
                                              double
                                            >(0),
                                      ),
                                      child: viewModel.isCheckingEmail
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
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
                          ),

                          // 에러 메시지 표시
                          if (viewModel.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: Color(0xFFFF5252),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // 비밀번호
                          TextField(
                            controller: _passwordController,
                                                        obscureText: true,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              labelStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: '비밀번호를 입력하세요 (6자 이상)',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: const Color.fromRGBO(
                                130,
                                145,
                                179,
                                0.1333,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 비밀번호 확인
                          TextField(
                            controller: _passwordConfirmController,
                                                        obscureText: true,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              labelText: '비밀번호를 다시 입력해주세요',
                              labelStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: '비밀번호를 다시 입력하세요',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: const Color.fromRGBO(
                                130,
                                145,
                                179,
                                0.1333,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[600]!,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          // 비밀번호 일치 여부 안내 텍스트
                          Builder(
                            builder: (_) {
                              final hasPassword =
                                  _passwordController.text.isNotEmpty;
                              final hasConfirm = _passwordConfirmController.text
                                  .isNotEmpty;
                              if (!hasPassword && !hasConfirm) {
                                return const SizedBox(height: 0);
                              }
                              final matches =
                                  _passwordController.text ==
                                  _passwordConfirmController.text;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  matches ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: matches
                                        ? const Color(0xFF00C853)
                                        : const Color(0xFFFF5252),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // 프로필 이미지 (원형) - 입력 필드 아래로 이동, 크기 확대
                          Center(
                            child: Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 56,
                                  backgroundColor: Color(0xFF2A2F3A),
                                  child: Icon(
                                    Icons.person,
                                    size: 56,
                                    color: Colors.white70,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: InkWell(
                                    onTap: _showComingSoon,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF3278),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 이름 또는 닉네임 (프로필 이미지 아래로 이동)
                          TextField(
                            controller: _nameController,
                                                        enabled: !viewModel.isExistingUser,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: viewModel.isExistingUser
                                  ? Colors.grey[400]
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              labelText: viewModel.isExistingUser
                                  ? null
                                  : '이름 또는 닉네임을 입력해주세요',
                              labelStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: '이름 또는 닉네임',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                color: viewModel.isExistingUser
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              filled: true,
                              fillColor: viewModel.isExistingUser
                                  ? Colors.grey[800]
                                  : const Color.fromRGBO(130, 145, 179, 0.1333),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: viewModel.isExistingUser
                                      ? Colors.grey[700]!
                                      : Colors.grey[600]!,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          // 성별 선택 (신규 사용자만 표시)
                          if (!viewModel.isExistingUser) ...[
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '성별',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RadioGroup<String>(
                                  groupValue: viewModel.selectedGender,
                                  onChanged: viewModel.selectGender,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: Text(
                                            '남성',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          value: 'male',
                                          activeColor: const Color(0xFFFF3278),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          title: Text(
                                            '여성',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          value: 'female',
                                          activeColor: const Color(0xFFFF3278),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 12),
                          Container(height: 1, color: Colors.grey[700]),
                          const SizedBox(height: 12),

                          // 이용약관 동의 섹션
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                130,
                                145,
                                179,
                                0.1333,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 이용약관 제목
                                Text(
                                  '이용약관',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 약관 동의 항목들
                                TermsRow(
                                  label: '[필수] 이용약관 동의',
                                  checked: viewModel.agreeTerms1,
                                  onChanged: (v) => viewModel.toggleTerms1(),
                                  onView: _showComingSoon,
                                ),
                                TermsRow(
                                  label: '[필수] 개인정보 처리방침 동의',
                                  checked: viewModel.agreeTerms2,
                                  onChanged: (v) => viewModel.toggleTerms2(),
                                  onView: _showComingSoon,
                                ),
                                TermsRow(
                                  label: '[필수] 만 14세 이상입니다',
                                  checked: viewModel.agreeTerms3,
                                  onChanged: (v) => viewModel.toggleTerms3(),
                                  onView: _showComingSoon,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 하단 고정 회원가입 버튼
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.canSubmit
                            ? () => viewModel.handleSubmit(widget.phoneNumber)
                            : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith(
                            (states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey[700];
                              }
                              return const Color(0xFFFF3278);
                            },
                          ),
                          foregroundColor:
                              const WidgetStatePropertyAll<Color>(Colors.white),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          elevation:
                              const WidgetStatePropertyAll<double>(0),
                        ),
                        child: Text(
                          viewModel.isExistingUser ? '연동하기' : '회원가입',
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
        },
      ),
    );
  }
}
