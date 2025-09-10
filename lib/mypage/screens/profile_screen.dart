import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:boulderside_flutter/core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 섹션
            Builder(
              builder: (context) {
                final userStore = context.watch<UserStore>();
                final user = userStore.user;
                return Row(
                  children: [
                    // 프로필 이미지
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user?.profileImageUrl ??
                              'https://lhj-s3-1.s3.ap-northeast-2.amazonaws.com/profile/53ca0dcc-95db-4460-afcf-c352af4f89e7_logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 이름과 로그아웃 버튼
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nickname ?? '로그인 필요',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              _showLogoutDialog(context, userStore);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3278),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('로그아웃'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performLogout(BuildContext context, UserStore userStore) async {
    // 1. 토큰 삭제 (access, refresh, auto_login = false)
    await TokenStore.clearTokens();

    // 2. UserStore에서 사용자 정보 삭제
    await userStore.clearUser();

    // 3. 로그인 화면으로 이동
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  void _showLogoutDialog(BuildContext context, UserStore userStore) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262A34),
          title: const Text(
            '로그아웃',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
          content: const Text(
            '정말 로그아웃하시겠습니까?',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context, userStore);
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
}
