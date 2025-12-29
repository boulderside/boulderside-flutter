import 'package:boulderside_flutter/src/core/notifications/models/app_notification.dart';
import 'package:boulderside_flutter/src/core/notifications/providers/notification_providers.dart';
import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_instagram_detail_use_case.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/liked_instagram_detail_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/notice_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationStoreProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationStoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            '알림',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmClearAll(context),
            child: const Text(
              '모두 지우기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                '수신한 알림이 없습니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white54,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[850]),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: const Color(0xFF3A1F1F),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  onDismissed: (_) {
                    ref
                        .read(notificationStoreProvider.notifier)
                        .removeById(item.id);
                  },
                  child: _NotificationCard(
                    item: item,
                    onTap: () => _handleNotificationTap(context, item),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262A34),
          title: const Text(
            '알림을 모두 지울까요?',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            '수신한 알림이 전부 삭제됩니다.',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white60,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      ref.read(notificationStoreProvider.notifier).clear();
    }
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    AppNotification item,
  ) async {
    final domainId = int.tryParse(item.domainId ?? '');
    if (domainId == null) {
      _showError(context, '알림 정보를 불러올 수 없습니다.');
      return;
    }

    switch (item.domainType) {
      case NotificationDomainType.notice:
        _markAsRead(item.id);
        context.push(
          AppRoutes.noticeDetail,
          extra: NoticeDetailArgs(noticeId: domainId),
        );
        return;
      case NotificationDomainType.boulder:
        await _openBoulderDetail(context, domainId, item.id);
        return;
      case NotificationDomainType.route:
        await _openRouteDetail(context, domainId, item.id);
        return;
      case NotificationDomainType.instagram:
        await _openInstagramDetail(context, domainId, item.id);
        return;
      case NotificationDomainType.matePost:
        await _openMatePostDetail(context, domainId, item.id);
        return;
      case NotificationDomainType.boardPost:
        await _openBoardPostDetail(context, domainId, item.id);
        return;
    }
  }

  Future<void> _openBoulderDetail(
    BuildContext context,
    int boulderId,
    String notificationId,
  ) async {
    try {
      final boulder = await _runWithLoading(
        context,
        () => di<BoulderDetailService>().fetchDetail(boulderId),
      );
      if (boulder == null) return;
      if (!context.mounted) return;
      _markAsRead(notificationId);
      context.push(AppRoutes.boulderDetail, extra: boulder);
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, '바위 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _openRouteDetail(
    BuildContext context,
    int routeId,
    String notificationId,
  ) async {
    try {
      final detail = await _runWithLoading(
        context,
        () => di<RouteDetailService>().fetchDetail(routeId),
      );
      if (detail == null) return;
      if (!context.mounted) return;
      _markAsRead(notificationId);
      context.push(AppRoutes.routeDetail, extra: detail.route);
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, '루트 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _openInstagramDetail(
    BuildContext context,
    int instagramId,
    String notificationId,
  ) async {
    try {
      final detail = await _runWithLoading(context, () async {
        final result = await di<FetchInstagramDetailUseCase>()(instagramId);
        return result.data;
      });
      if (detail == null) {
        if (!context.mounted) return;
        _showError(context, '인스타그램 정보를 불러오지 못했습니다.');
        return;
      }
      final instagram = Instagram(
        id: detail.id,
        url: detail.url,
        routeIds: detail.routes.map((e) => e.routeId).toList(),
        likeCount: detail.likeCount,
        liked: detail.liked,
        userInfo: detail.userInfo,
        createdAt: detail.createdAt,
      );
      if (!context.mounted) return;
      _markAsRead(notificationId);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LikedInstagramDetailScreen(instagram: instagram),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, '인스타그램 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _openMatePostDetail(
    BuildContext context,
    int postId,
    String notificationId,
  ) async {
    try {
      final response = await _runWithLoading(
        context,
        () => di<MatePostService>().fetchPost(postId),
      );
      if (response == null) return;
      if (!context.mounted) return;
      _markAsRead(notificationId);
      context.push(
        AppRoutes.communityCompanionDetail,
        extra: response.toCompanionPost(),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, '동행글 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _openBoardPostDetail(
    BuildContext context,
    int postId,
    String notificationId,
  ) async {
    try {
      final response = await _runWithLoading(
        context,
        () => di<BoardPostService>().fetchPost(postId),
      );
      if (response == null) return;
      if (!context.mounted) return;
      _markAsRead(notificationId);
      context.push(
        AppRoutes.communityBoardDetail,
        extra: response.toBoardPost(),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, '게시글 정보를 불러오지 못했습니다.');
    }
  }

  Future<T?> _runWithLoading<T>(
    BuildContext context,
    Future<T> Function() task,
  ) async {
    if (!context.mounted) return null;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      ),
    );
    try {
      return await task();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _markAsRead(String id) {
    if (id.isEmpty) return;
    ref.read(notificationStoreProvider.notifier).markReadById(id);
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, this.onTap});

  final AppNotification item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIcon(domainType: item.domainType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.body.isNotEmpty)
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(item.receivedAt),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}.$month.$day $hour:$minute';
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.domainType});

  final NotificationDomainType domainType;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(domainType);
    final color = _colorForType(domainType);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  IconData _iconForType(NotificationDomainType domainType) {
    switch (domainType) {
      case NotificationDomainType.boulder:
        return Icons.landscape_outlined;
      case NotificationDomainType.route:
        return Icons.alt_route_outlined;
      case NotificationDomainType.instagram:
        return Icons.photo_camera_outlined;
      case NotificationDomainType.matePost:
        return Icons.people_outline;
      case NotificationDomainType.boardPost:
        return Icons.article_outlined;
      case NotificationDomainType.notice:
        return Icons.campaign_outlined;
    }
  }

  Color _colorForType(NotificationDomainType domainType) {
    switch (domainType) {
      case NotificationDomainType.boulder:
        return const Color(0xFF6DD3A6);
      case NotificationDomainType.route:
        return const Color(0xFF6FA8FF);
      case NotificationDomainType.instagram:
        return const Color(0xFFFF7A7A);
      case NotificationDomainType.matePost:
        return const Color(0xFFFFC857);
      case NotificationDomainType.boardPost:
        return const Color(0xFFB18CFF);
      case NotificationDomainType.notice:
        return const Color(0xFFFF3278);
    }
  }
}
