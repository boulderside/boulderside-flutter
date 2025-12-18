import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/application/signup_view_model.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/oauth_signup_payload.dart';
import 'package:boulderside_flutter/src/shared/constants/terms_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key, this.signupPayload});

  final OAuthSignupPayload? signupPayload;

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
    final initialNickname = ref
        .read(signupViewModelProvider(widget.signupPayload))
        .nickname;
    _nicknameController = TextEditingController(text: initialNickname);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final success = await ref
        .read(signupViewModelProvider(widget.signupPayload).notifier)
        .completeSignup();

    if (!mounted) return;

    if (success) {
      final nickname = ref
          .read(signupViewModelProvider(widget.signupPayload))
          .nickname;
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

  void _showTermsDetails(BuildContext context, String title, String content) {
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
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
                    child: Text(
                      content,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                        height: 1.6,
                      ),
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
    final provider = signupViewModelProvider(widget.signupPayload);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);

    ref.listen(provider, (previous, next) {
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
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Agree All
                    InkWell(
                      onTap: () =>
                          viewModel.toggleAllTerms(!state.isAllTermsAccepted),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: state.isAllTermsAccepted,
                                activeColor: _accentColor,
                                checkColor: Colors.white,
                                side: BorderSide(color: Colors.grey[600]!),
                                onChanged: viewModel.toggleAllTerms,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '약관 전체 동의하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[800],
                      indent: 16,
                      endIndent: 16,
                    ),
                    // Age
                    _TermsItem(
                      label: '(필수) 만 14세 이상입니다.',
                      value: state.isAgeVerified,
                      onChanged: viewModel.toggleAgeVerification,
                    ),
                    // Service
                    _TermsItem(
                      label: '(필수) 서비스 이용약관 동의',
                      value: state.isServiceTermsAccepted,
                      onChanged: viewModel.toggleServiceTerms,
                      onDetailTap: () => _showTermsDetails(
                        context,
                        '서비스 이용약관',
                        TermsText.serviceTerms,
                      ),
                    ),
                    // Privacy
                    _TermsItem(
                      label: '(필수) 개인정보 수집 및 이용 동의',
                      value: state.isPrivacyPolicyAccepted,
                      onChanged: viewModel.togglePrivacyPolicy,
                      onDetailTap: () => _showTermsDetails(
                        context,
                        '개인정보 수집 및 이용 동의',
                        TermsText.privacyPolicy,
                      ),
                    ),
                    // Marketing
                    _TermsItem(
                      label: '(선택) 마케팅 정보 수신 동의',
                      value: state.isMarketingConsentAccepted,
                      onChanged: viewModel.toggleMarketingConsent,
                      onDetailTap: () => _showTermsDetails(
                        context,
                        '마케팅 정보 수신 동의',
                        TermsText.marketingTerms,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        (state.isAllRequiredTermsAccepted && state.isAvailable)
                        ? _accentColor
                        : Colors
                              .grey
                              .shade700, // Distinct disabled background color
                    foregroundColor:
                        (state.isAllRequiredTermsAccepted && state.isAvailable)
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
                  onPressed:
                      (state.isAllRequiredTermsAccepted && state.isAvailable)
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

class _TermsItem extends StatelessWidget {
  const _TermsItem({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onDetailTap,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onDetailTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                activeColor: const Color(0xFFFF3278),
                checkColor: Colors.white,
                side: BorderSide(color: Colors.grey[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            if (onDetailTap != null)
              GestureDetector(
                onTap: onDetailTap,
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
