import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_likes_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_posts_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Consumer<UserStore>(
            builder: (context, userStore, _) {
              return _ProfileHeader(
                userStore: userStore,
                onLogout: () => _showLogoutDialog(context, userStore),
              );
            },
          ),
          const SizedBox(height: 24),
          _ProfileMenuSection(
            items: [
              _ProfileMenuItemData(
                label: '나의 루트',
                onTap: () => _openMyRoutes(context),
              ),
              _ProfileMenuItemData(
                label: '나의 게시글',
                onTap: () => _openMyPosts(context),
              ),
              _ProfileMenuItemData(
                label: '나의 좋아요',
                onTap: () => _openMyLikes(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openMyRoutes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyRoutesScreen(),
      ),
    );
  }

  void _openMyPosts(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyPostsScreen(),
      ),
    );
  }

  void _openMyLikes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyLikesScreen(),
      ),
    );
  }

  Future<void> _performLogout(
    BuildContext context,
    UserStore userStore,
  ) async {
    await TokenStore.clearTokens();
    await userStore.clearUser();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _showLogoutDialog(BuildContext context, UserStore userStore) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userStore,
    required this.onLogout,
  });

  final UserStore userStore;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = userStore.user;
    return Row(
      children: [
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
                onPressed: onLogout,
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
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.items});

  final List<_ProfileMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Column(
              children: [
                _ProfileMenuRow(data: item),
                if (item != items.last)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.data});

  final _ProfileMenuItemData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Text(
              data.label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItemData {
  _ProfileMenuItemData({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}
