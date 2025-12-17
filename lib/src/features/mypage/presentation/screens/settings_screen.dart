import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/shared/constants/terms_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const Color _backgroundColor = Color(0xFF181A20);
  static const Color _cardColor = Color(0xFF262A34);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;

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
    return Scaffold(
      backgroundColor: SettingsScreen._backgroundColor,
      appBar: AppBar(
        backgroundColor: SettingsScreen._backgroundColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          '설정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: '알림',
            children: [
              SwitchListTile(
                value: _pushEnabled,
                onChanged: (value) {
                  setState(() => _pushEnabled = value);
                },
                activeThumbColor: const Color(0xFFFF3278),
                title: const Text(
                  '알림 설정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  _pushEnabled ? '푸시 알림이 켜져 있어요.' : '푸시 알림이 꺼져 있어요.',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: '계정',
            children: [
              _SettingsTile(
                label: '로그아웃',
                onTap: () => _confirmLogout(context),
              ),
              _SettingsTile(
                label: '회원탈퇴',
                onTap: () {
                  // TODO: 구현 예정
                },
              ),
              _SettingsTile(
                label: '차단한 사용자 관리',
                onTap: () {
                  // TODO: 구현 예정
                },
              ),
            ],
          ),
          _SettingsSection(
            title: '법적 고지',
            children: [
              _SettingsTile(
                label: '서비스 이용약관',
                onTap: () => _showTermsDetails(
                  context,
                  '서비스 이용약관',
                  TermsText.serviceTerms,
                ),
              ),
              _SettingsTile(
                label: '개인정보 수집 및 이용 동의',
                onTap: () => _showTermsDetails(
                  context,
                  '개인정보 수집 및 이용 동의',
                  TermsText.privacyPolicy,
                ),
              ),
              _SettingsTile(
                label: '마케팅 정보 수신 동의',
                onTap: () => _showTermsDetails(
                  context,
                  '마케팅 정보 수신 동의',
                  TermsText.marketingTerms,
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: '앱 정보',
            children: const [
              ListTile(
                title: Text(
                  '앱 버전 정보',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SettingsScreen._cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0x11FFFFFF)),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    );
  }
}

void _confirmLogout(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '로그아웃',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: const Text(
          '정말 로그아웃하시겠습니까?',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              dialogContext.pop();
              await GetIt.I<AuthRepository>().logout();
              await GetIt.I<UserStore>().clearUser();
              if (!context.mounted) return;
              context.go(AppRoutes.login);
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFFF3278),
              ),
            ),
          ),
        ],
      );
    },
  );
}
