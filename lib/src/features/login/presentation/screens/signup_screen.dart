import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/application/signup_view_model.dart';
import 'package:boulderside_flutter/src/shared/constants/terms_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final TextEditingController _nicknameController;

  static const _accentColor = Color(0xFFFF3278);
  static const _backgroundColor = Color(0xFF181A20);
  static const _cardColor = Color(0xFF1F222A);

  @override
  void initState() {
    super.initState();
    // Initialize controller with the random nickname from ViewModel
    final initialNickname = ref.read(signupViewModelProvider).nickname;
    _nicknameController = TextEditingController(text: initialNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final success = await ref
        .read(signupViewModelProvider.notifier)
        .completeSignup();

    if (!mounted) return;

    if (success) {
      final nickname = ref.read(signupViewModelProvider).nickname;
      context.go(AppRoutes.home);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$nickname님, 환영합니다!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F222A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '이용약관 및 개인정보 처리방침',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '서비스 이용약관',
                          style: TextStyle(
                            color: Color(0xFFFF3278),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TermsText.serviceTerms,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 32),
                        const Text(
                          '개인정보 처리방침',
                          style: TextStyle(
                            color: Color(0xFFFF3278),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TermsText.privacyPolicy,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3278),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '확인',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupViewModelProvider);
    final viewModel = ref.read(signupViewModelProvider.notifier);

    ref.listen(signupViewModelProvider, (previous, next) {
      if (previous?.nickname != next.nickname &&
          _nicknameController.text != next.nickname) {
        _nicknameController.text = next.nickname;
      }
    });

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '서비스 이용을 위해\n약관 동의와 닉네임 설정이 필요해요.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Terms Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: state.isTermsAccepted,
                      activeColor: _accentColor,
                      checkColor: Colors.white,
                      side: BorderSide(color: Colors.grey[600]!),
                      onChanged: viewModel.toggleTerms,
                    ),
                    const Expanded(
                      child: Text(
                        '이용약관 및 개인정보 처리방침에 동의합니다. (필수)',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.grey),
                      onPressed: () => _showTermsSheet(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nickname Section
              const Text(
                '닉네임',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nicknameController,
                style: const TextStyle(color: Colors.white),
                onChanged: viewModel.setNickname,
                decoration: InputDecoration(
                  hintText: '사용할 닉네임을 입력하세요',
                  hintStyle: TextStyle(color: Colors.white.withAlpha(76)),
                  filled: true,
                  fillColor: _cardColor,
                  prefixIcon: IconButton(
                    onPressed: viewModel.generateRandomNickname,
                    icon: const Icon(Icons.casino),
                    color: Colors.white70,
                    tooltip: '랜덤 닉네임 생성',
                  ),
                  suffixIcon: state.isChecking
                      ? Transform.scale(
                          scale: 0.4,
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            color: _accentColor,
                          ),
                        )
                      : TextButton(
                          onPressed: viewModel.checkAvailability,
                          child: const Text(
                            '중복확인',
                            style: TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: _accentColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                ),
              ),
              if (state.statusMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text(
                    state.statusMessage!,
                    style: TextStyle(color: state.statusColor, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 48),

              // Complete Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (state.isTermsAccepted && state.isAvailable)
                        ? _accentColor
                        : Colors
                              .grey
                              .shade700, // Distinct disabled background color
                    foregroundColor:
                        (state.isTermsAccepted && state.isAvailable)
                        ? Colors.white
                        : Colors
                              .grey
                              .shade400, // Distinct disabled foreground color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  onPressed: (state.isTermsAccepted && state.isAvailable)
                      ? _handleComplete
                      : null,
                  child: const Text(
                    '가입 완료',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
