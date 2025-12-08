import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/application/login_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'phone_verification_screen.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginStoreProvider, (previous, next) {
      if (next.loginSucceeded && !(previous?.loginSucceeded ?? false)) {
        if (!mounted) return;
        context.go(AppRoutes.home);
        ref.read(loginStoreProvider.notifier).consumeSuccess();
      }

      final String? nextError = next.errorMessage;
      if (nextError != null && nextError != previous?.errorMessage) {
        _showErrorDialog(context, nextError);
        ref.read(loginStoreProvider.notifier).clearError();
      }
    });

    final loginState = ref.watch(loginStoreProvider);
    final loginStore = ref.read(loginStoreProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logo/boulderside_main_logo.png',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '이메일을 입력하세요',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '비밀번호를 입력하세요',
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: Colors.grey[400],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(130, 145, 179, 0.1333),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: loginState.isAutoLoginEnabled,
                          onChanged: (bool? value) {
                            loginStore.toggleAutoLogin(value ?? false);
                          },
                          activeColor: const Color(0xFFFF3278),
                          checkColor: Colors.white,
                        ),
                        const Text(
                          '자동 로그인',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loginState.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3278),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: loginState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                '로그인',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: loginState.isLoading ? null : _handleSignUp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[600]!),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '이메일로 가입하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: loginState.isLoading ? null : _handleFindId,
                    child: const Text(
                      '아이디 찾기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFFFF3278),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    ' | ',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextButton(
                    onPressed: loginState.isLoading
                        ? null
                        : _handleResetPassword,
                    child: const Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFFFF3278),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(loginStoreProvider.notifier).login(email, password);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2D3A),
          title: const Text(
            '로그인 실패',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF3278),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // TODO: 회원가입 화면으로 이동
  void _handleSignUp() {
    context.push(AppRoutes.signUp);
  }

  // 아이디 찾기 화면으로 이동
  void _handleFindId() {
    context.push(
      AppRoutes.phoneVerification,
      extra: VerificationPurpose.findId,
    );
  }

  // 비밀번호 재설정 화면으로 이동
  void _handleResetPassword() {
    context.push(
      AppRoutes.phoneVerification,
      extra: VerificationPurpose.resetPassword,
    );
  }
}
