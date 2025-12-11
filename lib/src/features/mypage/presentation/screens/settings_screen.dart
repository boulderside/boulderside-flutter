import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const Color _backgroundColor = Color(0xFF181A20);
  static const Color _cardColor = Color(0xFF262A34);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;

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
                onTap: () {
                  // TODO: 구현 예정
                },
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
                label: '이용약관',
                onTap: () {
                  // TODO: 구현 예정
                },
              ),
              _SettingsTile(
                label: '개인정보처리방침',
                onTap: () {
                  // TODO: 구현 예정
                },
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
