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
  bool? _pushEnabled;
  bool _marketingConsentAgreed = false;
  bool _isUpdatingMarketingConsent = false;
  bool _isUpdatingPush = false;

  @override
  void initState() {
    super.initState();
    final user = GetIt.I<UserStore>().user;
    _marketingConsentAgreed = user?.marketingConsentAgreed ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserMeta());
  }

  Future<void> _loadUserMeta() async {
    try {
      final meta = await GetIt.I<AuthRepository>().fetchUserMeta();
      if (!mounted) return;
      setState(() {
        _pushEnabled = meta.pushEnabled;
        _marketingConsentAgreed = meta.marketingAgreed;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _showTermsDetails(
    BuildContext context,
    String title,
    String content, {
    String primaryButtonText = '확인',
    Future<void> Function(BuildContext sheetContext)? onPrimaryPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F222A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (sheetBodyContext, scrollController) {
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
                        backgroundColor: primaryButtonText == '철회'
                            ? const Color(0xFF3A3D47)
                            : const Color(0xFFFF3278),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (onPrimaryPressed != null) {
                          await onPrimaryPressed(sheetContext);
                        } else {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(
                        primaryButtonText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showMarketingConsentSheet(bool nextValue) {
    _showTermsDetails(
      context,
      '마케팅 정보 수신 동의',
      TermsText.marketingTerms,
      primaryButtonText: nextValue ? '동의' : '철회',
      onPrimaryPressed: (sheetContext) async {
        Navigator.pop(sheetContext);
        await _toggleMarketingConsent(nextValue);
      },
    );
  }

  Future<void> _toggleMarketingConsent(bool value) async {
    if (_isUpdatingMarketingConsent || _marketingConsentAgreed == value) {
      return;
    }

    final previousValue = _marketingConsentAgreed;
    setState(() {
      _marketingConsentAgreed = value;
      _isUpdatingMarketingConsent = true;
    });

    try {
      final serverAgreed = await GetIt.I<AuthRepository>()
          .updateMarketingConsent(agreed: value);
      if (!mounted) return;
      setState(() {
        _marketingConsentAgreed = serverAgreed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _marketingConsentAgreed = previousValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('마케팅 정보 수신 동의 변경에 실패했습니다. 잠시 후 다시 시도해주세요.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingMarketingConsent = false;
        });
      }
    }
  }

  Future<void> _togglePush(bool value) async {
    if (_pushEnabled == null || _isUpdatingPush || _pushEnabled == value) {
      return;
    }

    final previousValue = _pushEnabled!;
    setState(() {
      _pushEnabled = value;
      _isUpdatingPush = true;
    });

    try {
      final serverEnabled = await GetIt.I<AuthRepository>().updatePushConsent(
        agreed: value,
      );
      if (!mounted) return;
      setState(() {
        _pushEnabled = serverEnabled;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pushEnabled = previousValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 설정 변경에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPush = false;
        });
      }
    }
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
                value: _pushEnabled ?? false,
                onChanged: (_pushEnabled == null || _isUpdatingPush)
                    ? null
                    : (value) => _togglePush(value),
                activeThumbColor: const Color(0xFFFF3278),
                title: const Text(
                  '알림 설정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  _pushEnabled == true ? '푸시 알림이 켜져 있어요.' : '푸시 알림이 꺼져 있어요.',
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
                onTap: () => context.push(AppRoutes.withdrawal),
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
            title: '지원',
            children: [
              _SettingsTile(
                label: '문의하기',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF262A34),
                      title: const Text(
                        '문의하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '아래 이메일로 문의해주시면\n빠르게 답변드리겠습니다.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2330),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'linechillstudio@gmail.com',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              color: Color(0xFFFF3278),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                label: '공지사항',
                onTap: () => context.push(AppRoutes.noticeList),
              ),
              _SettingsTile(
                label: '신고 내역',
                onTap: () => context.push(AppRoutes.reportHistory),
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
              SwitchListTile(
                value: _marketingConsentAgreed,
                onChanged: _isUpdatingMarketingConsent
                    ? null
                    : (value) => _showMarketingConsentSheet(value),
                activeThumbColor: const Color(0xFFFF3278),
                title: const Text(
                  '마케팅 정보 수신 동의',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                  ),
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
