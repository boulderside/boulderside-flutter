import 'package:boulderside_flutter/src/features/mypage/application/blocked_users_store.dart';
import 'package:boulderside_flutter/src/shared/widgets/avatar_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  static const Color _backgroundColor = Color(0xFF181A20);
  static const Color _cardColor = Color(0xFF262A34);

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blockedUsersStoreProvider.notifier).loadBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blockedUsersStoreProvider);

    return Scaffold(
      backgroundColor: BlockedUsersScreen._backgroundColor,
      appBar: AppBar(
        backgroundColor: BlockedUsersScreen._backgroundColor,
        foregroundColor: Colors.white,
        title: const Text(
          '차단한 사용자 관리',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BlockedUsersState state) {
    if (state.isLoading && state.blockedUsers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (state.errorMessage != null && state.blockedUsers.isEmpty) {
      return _ErrorRetry(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(blockedUsersStoreProvider.notifier).loadBlockedUsers(),
      );
    }

    if (state.blockedUsers.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      backgroundColor: const Color(0xFF262A34),
      color: const Color(0xFFFF3278),
      onRefresh: () =>
          ref.read(blockedUsersStoreProvider.notifier).loadBlockedUsers(),
      child: ListView.separated(
        itemCount: state.blockedUsers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = state.blockedUsers[index];
          final isProcessing = state.processingUserIds.contains(user.id);
          return Container(
            decoration: BoxDecoration(
              color: BlockedUsersScreen._cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AvatarPlaceholder(size: 44, imageUrl: user.profileImageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBlockedAt(user.blockedAt),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () => _confirmUnblock(user.id, user.nickname),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3278),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('차단 해제'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmUnblock(int userId, String nickname) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '차단 해제',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: Text(
          '$nickname 님을 차단 해제할까요?',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              '취소',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '해제',
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

    if (confirmed == true) {
      final success = await ref
          .read(blockedUsersStoreProvider.notifier)
          .unblockUser(userId);
      if (!mounted || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '$nickname 님을 차단 해제했어요.' : '차단 해제에 실패했습니다.'),
          backgroundColor: success ? null : Colors.red,
        ),
      );
    }
  }

  String _formatBlockedAt(DateTime? blockedAt) {
    if (blockedAt == null) return '차단일을 확인할 수 없어요.';
    return '${blockedAt.year}.${blockedAt.month.toString().padLeft(2, '0')}.${blockedAt.day.toString().padLeft(2, '0')} 차단';
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BlockedUsersScreen._cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFF3278)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '차단한 사용자와는 서로의 게시글과 댓글이 표시되지 않아요.',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.sentiment_satisfied, color: Colors.white54, size: 48),
          SizedBox(height: 12),
          Text(
            '차단한 사용자가 없어요.',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3278),
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
