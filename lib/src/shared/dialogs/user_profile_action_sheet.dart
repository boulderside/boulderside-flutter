import 'package:boulderside_flutter/src/features/community/data/models/user_info.dart';
import 'package:boulderside_flutter/src/features/mypage/application/blocked_users_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showUserProfileActionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required UserInfo userInfo,
  bool isMine = false,
}) async {
  if (isMine) return;

  final store = ref.read(blockedUsersStoreProvider.notifier);
  await store.ensureLoaded();
  if (!context.mounted) return;
  final isBlocked = ref.read(blockedUsersStoreProvider).isBlocked(userInfo.id);

  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: const Color(0xFF1F222A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: userInfo.profileImageUrl != null
                        ? NetworkImage(userInfo.profileImageUrl!)
                        : null,
                    backgroundColor: const Color(0xFF262A34),
                    child: userInfo.profileImageUrl == null
                        ? const Icon(Icons.person, color: Colors.white54)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo.nickname,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '차단 시 서로의 게시글과 댓글이 표시되지 않아요.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                onTap: () => Navigator.pop(
                  sheetContext,
                  isBlocked ? 'unblock' : 'block',
                ),
                tileColor: const Color(0xFF262A34),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  isBlocked ? Icons.undo : Icons.block,
                  color: isBlocked ? Colors.white : Colors.redAccent,
                ),
                title: Text(
                  isBlocked ? '차단 해제' : '차단하기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: isBlocked ? Colors.white : Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (action == null) return;

  switch (action) {
    case 'block':
      final success = await store.blockUser(userInfo.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${userInfo.nickname} 님을 차단했어요. 설정 > 차단한 사용자 관리에서 관리할 수 있어요.'
                : '사용자를 차단하지 못했습니다. 잠시 후 다시 시도해주세요.',
          ),
          backgroundColor: success ? null : Colors.red,
        ),
      );
      break;
    case 'unblock':
      final success = await store.unblockUser(userInfo.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '${userInfo.nickname} 님의 차단을 해제했어요.' : '차단 해제에 실패했습니다.',
          ),
          backgroundColor: success ? null : Colors.red,
        ),
      );
      break;
  }
}
