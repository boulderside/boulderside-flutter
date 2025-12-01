import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/src/features/login/data/services/phone_verification_service.dart';
import 'package:boulderside_flutter/src/features/login/presentation/viewmodels/phone_verification_view_model.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';

enum VerificationPurpose {
  findId, // 아이디 찾기
  resetPassword, // 비밀번호 재설정
}

class PhoneVerificationScreen extends StatefulWidget {
  final VerificationPurpose purpose;

  const PhoneVerificationScreen({super.key, required this.purpose});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  static const int _timerDuration = 180; // 3분

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startTimer() {
    _remainingSeconds = _timerDuration;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {});
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingSeconds = 0;
  }

  String _getTitle() {
    switch (widget.purpose) {
      case VerificationPurpose.findId:
        return '아이디 찾기';
      case VerificationPurpose.resetPassword:
        return '비밀번호 재설정';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PhoneVerificationViewModel(
        context.read<PhoneVerificationService>(),
      ),
      child: Consumer<PhoneVerificationViewModel>(
        builder: (context, viewModel, child) {
          // 인증번호 전송
          Future<void> sendCode() async {
            await viewModel.sendVerificationCode(_phoneController.text.trim());

            if (!context.mounted) return;

            if (viewModel.isCodeSent) {
              _startTimer();
            }

            if (viewModel.errorMessage != null) {
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
            }
          }

          // 인증번호 검증
          Future<void> verifyCode() async {
            await viewModel.verifyCode(
              _phoneController.text.trim(),
              _codeController.text.trim(),
            );

            if (!context.mounted) return;

            if (viewModel.isCodeVerified) {
              _stopTimer();

              // 인증 성공 시 아이디 찾기 API 호출 (둘 다 필요)
              await viewModel.findIdByPhone(_phoneController.text.trim());

              if (!context.mounted) return;

              // 목적에 따라 다른 화면으로 이동
              final navigator = Navigator.of(context);
              switch (widget.purpose) {
                case VerificationPurpose.findId:
                  if (viewModel.foundEmail != null) {
                    navigator.pushReplacementNamed(
                      AppRoutes.findIdResult,
                      arguments: {
                        'phoneNumber': _phoneController.text.trim(),
                        'email': viewModel.foundEmail,
                      },
                    );
                  }
                  break;
                case VerificationPurpose.resetPassword:
                  if (viewModel.foundEmail != null) {
                    navigator.pushReplacementNamed(
                      AppRoutes.resetPassword,
                      arguments: {
                        'phoneNumber': _phoneController.text.trim(),
                        'email': viewModel.foundEmail,
                      },
                    );
                  }
                  break;
              }
            }

            if (viewModel.errorMessage != null) {
              if (!context.mounted) return;
              // 모든 에러 메시지를 알림창으로 표시
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF2A2D3A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text(
                      '알림',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _codeController.text = ''; // 인증번호 입력칸 초기화
                          viewModel.reset(); // 에러 메시지 초기화
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
          }

          return Scaffold(
            backgroundColor: const Color(0xFF181A20),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _getTitle(),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // 안내 텍스트
                    Text(
                      '휴대폰 번호로 본인확인을 진행합니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 휴대폰 번호 입력 (내부에 인증번호 전송/재전송 버튼 포함)
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: '휴대폰 번호',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "'-' 없이 숫자만 입력",
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: Colors.grey[400],
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: viewModel.isLoading ? null : sendCode,
                            child: Text(
                              viewModel.isCodeSent ? '재전송' : '인증번호 전송',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: viewModel.isLoading
                                    ? Colors.grey[600]
                                    : const Color(0xFFFF3278),
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 인증번호 입력 필드 (타이머 표시)
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        labelText: '인증번호를 입력해주세요',
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: '6자리 인증번호',
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
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        suffixIcon: viewModel.isCodeSent
                            ? Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    _remainingSeconds > 0
                                        ? _formatTime(_remainingSeconds)
                                        : '00:00',
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),

                    const Spacer(),

                    // 인증번호 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isCodeSent && !viewModel.isLoading
                            ? verifyCode
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
                        child: viewModel.isLoading
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
                            : Text(
                                '인증번호 확인',
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
