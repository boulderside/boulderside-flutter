import 'dart:async';

import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/application/phone_verification_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum VerificationPurpose { findId, resetPassword }

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key, required this.purpose});

  final VerificationPurpose purpose;

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  static const int _timerDuration = 180;

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
        setState(() {
          _remainingSeconds = 0;
        });
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
    final verificationState = ref.watch(phoneVerificationStoreProvider);
    final store = ref.read(phoneVerificationStoreProvider.notifier);

    Future<void> sendCode() async {
      await store.sendVerificationCode(_phoneController.text.trim());
      if (!context.mounted) return;

      final latest = ref.read(phoneVerificationStoreProvider);
      if (latest.isCodeSent) {
        _startTimer();
      }

      final error = latest.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                error,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        store.resetTransientState();
      }
    }

    Future<void> verifyCode() async {
      await store.verifyCode(
        _phoneController.text.trim(),
        _codeController.text.trim(),
      );
      if (!context.mounted) return;

      var latest = ref.read(phoneVerificationStoreProvider);
      if (latest.isCodeVerified) {
        _stopTimer();
        await store.findIdByPhone(_phoneController.text.trim());
        latest = ref.read(phoneVerificationStoreProvider);
        if (!context.mounted) return;

        final email = latest.foundEmail;
        if (email != null) {
          switch (widget.purpose) {
            case VerificationPurpose.findId:
              context.go(
                AppRoutes.findIdResult,
                extra: {
                  'phoneNumber': _phoneController.text.trim(),
                  'email': email,
                },
              );
              break;
            case VerificationPurpose.resetPassword:
              context.go(
                AppRoutes.resetPassword,
                extra: {
                  'phoneNumber': _phoneController.text.trim(),
                  'email': email,
                },
              );
              break;
          }
        }
      }

      final error = latest.errorMessage;
      if (error != null) {
        if (!context.mounted) return;
        showDialog<void>(
          context: context,
          builder: (context) {
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
                error,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    _codeController.text = '';
                    store.resetTransientState();
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
          onPressed: () => context.pop(),
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
                      onTap: verificationState.isLoading ? null : sendCode,
                      child: Text(
                        verificationState.isCodeSent ? '재전송' : '인증번호 전송',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: verificationState.isLoading
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
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  suffixIcon: verificationState.isCodeSent
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
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      verificationState.isCodeSent &&
                          !verificationState.isLoading
                      ? verifyCode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: verificationState.isLoading
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
                          '인증번호 확인',
                          style: TextStyle(
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
  }
}
