import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/application/kakao_login_client.dart';
import 'package:boulderside_flutter/src/features/login/application/login_view_model.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/presentation/widgets/social_login_button.dart';
import 'package:boulderside_flutter/src/features/login/providers/login_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Login extends StatelessWidget {
  const Login({super.key, this.kakaoLoginClient, this.authRepository});

  final KakaoLoginClient? kakaoLoginClient;
  final AuthRepository? authRepository;

  @override
  Widget build(BuildContext context) {
    Widget child = const _LoginView();

    if (kakaoLoginClient != null || authRepository != null) {
      child = ProviderScope(
        overrides: [
          if (kakaoLoginClient != null)
            kakaoLoginClientProvider.overrideWithValue(kakaoLoginClient!),
          if (authRepository != null)
            authRepositoryProvider.overrideWithValue(authRepository!),
        ],
        child: child,
      );
    }

    return child;
  }
}

class _LoginView extends ConsumerWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoginState>(loginViewModelProvider, (previous, next) {
      final event = next.event;
      if (event == null) return;

      switch (event.type) {
        case LoginEventType.showMessage:
          if (event.message != null) {
            _showSnackBar(context, event.message!);
          }
          break;
        case LoginEventType.navigateHome:
          if (event.message != null) {
            _showSnackBar(context, event.message!);
          }
          _navigate(context, AppRoutes.home);
          break;
        case LoginEventType.navigateSignup:
          final payload = event.payload;
          if (payload != null) {
            _navigate(context, AppRoutes.signup, extra: payload);
          } else {
            _showSnackBar(context, '로그인 정보가 유효하지 않습니다. 다시 시도해주세요.');
          }
          break;
      }

      ref.read(loginViewModelProvider.notifier).clearEvent();
    });

    final state = ref.watch(loginViewModelProvider);
    final viewModel = ref.read(loginViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Color(0xFF181A20),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                        '로그인하고 동행자, 바위, 루트 정보를 만나보세요',
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
                        onPressed: () => viewModel.login('naver'),
                        isLoading: state.isLoading('naver'),
                      ),

                      const SizedBox(height: 16),

                      SocialLoginButton(
                        text: '카카오로 로그인하기',
                        backgroundColor: const Color(0xFFFEE500),
                        logoPath: 'assets/logo/kakaotalk_logo.png',
                        onPressed: () => viewModel.login('kakao'),
                        textColor: Colors.black87,
                        isLoading: state.isLoading('kakao'),
                      ),

                      const SizedBox(height: 16),

                      SocialLoginButton(
                        text: '애플로 로그인하기',
                        backgroundColor: Colors.black,
                        logoPath: 'assets/logo/apple_logo.png',
                        onPressed: () => viewModel.login('apple'),
                        isLoading: state.isLoading('apple'),
                      ),

                      const SizedBox(height: 16),

                      SocialLoginButton(
                        text: '구글로 로그인하기',
                        backgroundColor: Colors.white,
                        logoPath: 'assets/logo/google_logo.png',
                        onPressed: () => viewModel.login('google'),
                        textColor: Colors.black87,
                        borderColor: Colors.grey[300]!,
                        isLoading: state.isLoading('google'),
                      ),

                      const SizedBox(height: 32),

                      // 구분선
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
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
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void _navigate(BuildContext context, String route, {Object? extra}) {
  final goRouter = GoRouter.maybeOf(context);
  if (goRouter != null) {
    goRouter.go(route, extra: extra);
  } else {
    Navigator.of(context).pushReplacementNamed(route, arguments: extra);
  }
}

void _showSnackBar(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}
