import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_posts_store.dart';
import 'package:boulderside_flutter/src/shared/widgets/segmented_toggle_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({super.key});

  @override
  ConsumerState<MyPostsScreen> createState() => _MyPostsBody();
}

class _MyPostsBody extends ConsumerState<MyPostsScreen> {
  static const Color _backgroundColor = Color(0xFF181A20);
  MyPostsTab _activeTab = MyPostsTab.mate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPostsStoreProvider.notifier).loadInitial(_activeTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MyPostsBody._backgroundColor,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '내 게시글',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: _MyPostsBody._backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedToggleBar<MyPostsTab>(
                options: const [
                  SegmentOption(label: '동행글', value: MyPostsTab.mate),
                  SegmentOption(label: '게시글', value: MyPostsTab.board),
                ],
                selectedValue: _activeTab,
                onChanged: (tab) {
                  setState(() => _activeTab = tab);
                  ref.read(myPostsStoreProvider.notifier).loadInitial(tab);
                },
              ),
            ),
          ),
          Expanded(child: _PostsTab(postType: _activeTab)),
        ],
      ),
    );
  }
}

class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.postType});

  final MyPostsTab postType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = postType == MyPostsTab.board
        ? ref.watch(myBoardPostsFeedProvider)
        : ref.watch(myMatePostsFeedProvider);
    final store = ref.read(myPostsStoreProvider.notifier);

    if (feed.isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (feed.errorMessage != null && feed.items.isEmpty) {
      return _ErrorView(
        message: feed.errorMessage!,
        onRetry: () => store.refresh(postType),
      );
    }

    if (feed.items.isEmpty) {
      return const _EmptyView(message: '작성한 게시글이 없습니다.');
    }

    final posts = feed.items;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200 &&
            feed.hasNext &&
            !feed.isLoadingMore) {
          store.loadMore(postType);
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => store.refresh(postType),
        backgroundColor: const Color(0xFF262A34),
        color: const Color(0xFFFF3278),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 80),
          itemCount: posts.length + (feed.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= posts.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF3278)),
                ),
              );
            }

            if (postType == MyPostsTab.board) {
              final post = posts[index] as BoardPost;
              return _MyBoardPostCard(
                post: post,
                onRefresh: () => store.refresh(postType),
              );
            } else {
              final post = posts[index] as CompanionPost;
              return _MyCompanionPostCard(
                post: post,
                onRefresh: () => store.refresh(postType),
              );
            }
          },
        ),
      ),
    );
  }
}

class _MyBoardPostCard extends StatelessWidget {
  const _MyBoardPostCard({required this.post, this.onRefresh});

  final BoardPost post;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () async {
          await context.push<bool>(AppRoutes.communityBoardDetail, extra: post);
          if (!context.mounted) return;
          onRefresh?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 18, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    '${post.viewCount}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _timeAgo(post.createdAt),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inMinutes < 60) return '${duration.inMinutes}분 전';
    if (duration.inHours < 24) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    if (duration.inDays < 30) return '${(duration.inDays / 7).floor()}주 전';
    if (duration.inDays < 365) return '${(duration.inDays / 30).floor()}개월 전';
    return '${(duration.inDays / 365).floor()}년 전';
  }
}

class _MyCompanionPostCard extends StatelessWidget {
  const _MyCompanionPostCard({required this.post, this.onRefresh});

  final CompanionPost post;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () async {
          await context.push<bool>(
            AppRoutes.communityCompanionDetail,
            extra: post,
          );
          if (!context.mounted) return;
          onRefresh?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.meetingDateLabel.isNotEmpty
                    ? '모임일 : ${post.meetingDateLabel}'
                    : '모임일 정보 없음',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.visibility, size: 18, color: Colors.white54),
                  const SizedBox(width: 4),
                  Text(
                    '${post.viewCount}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _timeAgo(post.createdAt),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inMinutes < 60) return '${duration.inMinutes}분 전';
    if (duration.inHours < 24) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    if (duration.inDays < 30) return '${(duration.inDays / 7).floor()}주 전';
    if (duration.inDays < 365) return '${(duration.inDays / 30).floor()}개월 전';
    return '${(duration.inDays / 365).floor()}년 전';
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          message,
          style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
