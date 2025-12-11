import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/shared/widgets/avatar_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStoreProvider);
    final userStore = ref.read(userStoreProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
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
          _ProfileHeader(
            user: userState.user,
            onLogout: () => _showLogoutDialog(context, userStore),
          ),
          const SizedBox(height: 24),
          _ProfileMenuSection(
            items: [
              _ProfileMenuItemData(
                label: '프로젝트',
                onTap: () => _openMyRoutes(context),
              ),
              _ProfileMenuItemData(
                label: '내 게시글',
                onTap: () => _openMyPosts(context),
              ),
              _ProfileMenuItemData(
                label: '좋아요',
                onTap: () => _openMyLikes(context),
              ),
              _ProfileMenuItemData(
                label: '내 댓글',
                onTap: () => _openMyComments(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openMyRoutes(BuildContext context) {
    context.push(AppRoutes.myRoutes);
  }

  void _openMyPosts(BuildContext context) {
    context.push(AppRoutes.myPosts);
  }

  void _openMyLikes(BuildContext context) {
    context.push(AppRoutes.myLikes);
  }

  void _openMyComments(BuildContext context) {
    context.push(AppRoutes.myComments);
  }

  Future<void> _performLogout(BuildContext context, UserStore userStore) async {
    await GetIt.I<AuthRepository>().logout();
    await userStore.clearUser();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
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
              onPressed: () => dialogContext.pop(),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                dialogContext.pop();
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
  const _ProfileHeader({required this.user, required this.onLogout});

  final User? user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
            border: Border.all(color: Colors.grey[500]!, width: 1),
          ),
          child: AvatarPlaceholder(
            size: 76,
            imageUrl: user?.profileImageUrl,
            backgroundColor: Colors.grey[300] ?? const Color(0xFFE0E0E0),
            iconColor: Colors.grey[600] ?? Colors.grey,
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
