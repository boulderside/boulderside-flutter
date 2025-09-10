import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import 'phone_verification_screen.dart';

class FindIdResultScreen extends StatelessWidget {
  final String phoneNumber;
  final String? email;

  const FindIdResultScreen({super.key, required this.phoneNumber, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '아이디 찾기',
          style: TextStyle(
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
            children: [
              const SizedBox(height: 60),

              // 중앙 로고
              Center(
                child: Image.asset(
                  'assets/logo/boulderside_main_logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 5),

              // 안내 텍스트
              Text(
                '고객님의 ID는',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // 아이디 표시
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(130, 145, 179, 0.1333),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  email ?? 'NULL',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '입니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 70),

              // 로그인하기 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '로그인하기',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 비밀번호 재설정 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _handleResetPassword(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[600]!),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '비밀번호 재설정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    // 로그인 화면으로 이동
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.emailLogin,
      (route) => false,
    );
  }

  void _handleResetPassword(BuildContext context) {
    // 비밀번호 재설정 화면으로 이동
    Navigator.pushNamed(
      context,
      AppRoutes.phoneVerification,
      arguments: VerificationPurpose.resetPassword,
    );
  }
}
