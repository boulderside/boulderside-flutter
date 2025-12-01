import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/presentation/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  static const Map<String, String> _providerNames = {
    'naver': '네이버',
    'kakao': '카카오',
    'apple': '애플',
    'google': '구글',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // 중앙 위 이미지
              Center(
                child: Image.asset(
                  'assets/logo/boulderside_main_logo.png',
                  width: 190,
                  height: 190,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 5),

              // 메인 텍스트
              Text(
                '바위 위의 모든 순간을 함께!',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 서브 텍스트
              Text(
                '지금 로그인하고, 동행자, 정보, 장비까지 한번에 만나보세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 소셜 로그인 버튼들
              SocialLoginButton(
                text: '네이버로 로그인하기',
                backgroundColor: const Color(0xFF1EDD00),
                logoPath: 'assets/logo/naver_logo.png',
                onPressed: () => _handleSocialLogin('naver'),
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '카카오로 로그인하기',
                backgroundColor: const Color(0xFFFEE500),
                logoPath: 'assets/logo/kakaotalk_logo.png',
                onPressed: () => _handleSocialLogin('kakao'),
                textColor: Colors.black87,
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '애플로 로그인하기',
                backgroundColor: Colors.black,
                logoPath: 'assets/logo/apple_logo.png',
                onPressed: () => _handleSocialLogin('apple'),
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '구글로 로그인하기',
                backgroundColor: Colors.white,
                logoPath: 'assets/logo/google_logo.png',
                onPressed: () => _handleSocialLogin('google'),
                textColor: Colors.black87,
                borderColor: Colors.grey[300]!,
              ),

              const SizedBox(height: 32),

              // 구분선
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: Colors.grey[300]),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 이메일로 시작하기 버튼
              SocialLoginButton(
                text: '이메일로 시작하기',
                backgroundColor: Colors.blue,
                logoPath: 'assets/logo/email_logo.png',
                onPressed: () => _handleEmailLogin(),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // 통합된 소셜 로그인 핸들러
  Future<void> _handleSocialLogin(String provider) async {
    final providerName = _providerNames[provider];

    if (providerName == null) {
      _showSnackBar('지원하지 않는 로그인 방식입니다.');
      return;
    }

    _showSnackBar('$providerName 로그인은 현재 준비 중입니다. 이메일 로그인으로 진행해주세요.');
  }

  void _handleEmailLogin() async {
    context.push(AppRoutes.emailLogin);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
