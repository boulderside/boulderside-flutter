import 'package:flutter/material.dart';
import '../widgets/social_login_button.dart';
import '../../core/routes/app_routes.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  bool _isLoading = false;

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
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '카카오로 로그인하기',
                backgroundColor: const Color(0xFFFEE500),
                logoPath: 'assets/logo/kakaotalk_logo.png',
                onPressed: () => _handleSocialLogin('kakao'),
                textColor: Colors.black87,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '애플로 로그인하기',
                backgroundColor: Colors.black,
                logoPath: 'assets/logo/apple_logo.png',
                onPressed: () => _handleSocialLogin('apple'),
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),

              SocialLoginButton(
                text: '구글로 로그인하기',
                backgroundColor: Colors.white,
                logoPath: 'assets/logo/google_logo.png',
                onPressed: () => _handleSocialLogin('google'),
                textColor: Colors.black87,
                borderColor: Colors.grey[300]!,
                isLoading: _isLoading,
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
                isLoading: _isLoading,
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;

      switch (provider) {
        case 'kakao':
          break;
        case 'apple':
          break;
        case 'google':
          break;
        case 'naver':
          break;
        default:
          throw Exception('지원하지 않는 로그인 방식입니다.');
      }

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (mounted) {
        String providerName = '';
        switch (provider) {
          case 'kakao':
            providerName = '카카오';
            break;
          case 'apple':
            providerName = '애플';
            break;
          case 'google':
            providerName = '구글';
            break;
          case 'naver':
            providerName = '네이버';
            break;
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleEmailLogin() async {
    // 중복 클릭 방지
    if (_isLoading) return;

    Navigator.pushNamed(context, AppRoutes.emailLogin);
  }
}
