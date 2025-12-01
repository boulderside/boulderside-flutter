import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/board_detail.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/companion_detail.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_posts_service.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/viewmodels/my_posts_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyPostsViewModel>(
      create: (context) => MyPostsViewModel(
        context.read<MyPostsService>(),
      ),
      child: const _MyPostsBody(),
    );
  }
}

class _MyPostsBody extends StatefulWidget {
  const _MyPostsBody();

  static const Color _backgroundColor = Color(0xFF181A20);

  @override
  State<_MyPostsBody> createState() => _MyPostsBodyState();
}

class _MyPostsBodyState extends State<_MyPostsBody> {
  MyPostsTab _activeTab = MyPostsTab.mate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<MyPostsViewModel>();
      viewModel.ensurePrefetched(_activeTab);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MyPostsBody._backgroundColor,
      appBar: AppBar(
        title: const Text(
          '나의 게시글',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
              child: _PostsToggleBar(
                activeTab: _activeTab,
                onChanged: (tab) {
                  setState(() {
                    _activeTab = tab;
                  });
                  context.read<MyPostsViewModel>().ensurePrefetched(tab);
                },
              ),
            ),
          ),
          Expanded(
        child: _PostsTab(postType: _activeTab),
      ),
        ],
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  const _PostsTab({required this.postType});

  final MyPostsTab postType;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyPostsViewModel>(
      builder: (context, viewModel, _) {
        final posts = postType == MyPostsTab.board
            ? viewModel.boardPosts
            : viewModel.companionPosts;

        final isLoading = viewModel.isLoading(postType) && posts.isEmpty;
        final errorMessage = viewModel.errorMessage(postType);

        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF3278)),
          );
        }

        if (errorMessage != null && posts.isEmpty) {
          return _ErrorView(
            message: errorMessage,
            onRetry: () => viewModel.refresh(postType),
          );
        }

        if (posts.isEmpty) {
          return const _EmptyView(message: '작성한 게시글이 없습니다.');
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                viewModel.hasNext(postType) &&
                !viewModel.isLoadingMore(postType)) {
              viewModel.loadMore(postType);
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () => viewModel.refresh(postType),
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: posts.length + (viewModel.isLoadingMore(postType) ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  );
                }

                if (postType == MyPostsTab.board) {
                  final post = posts[index] as BoardPost;
                  return _MyBoardPostCard(post: post);
                } else {
                  final post = posts[index] as CompanionPost;
                  return _MyCompanionPostCard(post: post);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _PostsToggleBar extends StatelessWidget {
  const _PostsToggleBar({
    required this.activeTab,
    required this.onChanged,
  });

  final MyPostsTab activeTab;
  final ValueChanged<MyPostsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xAA1E2129),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PostsToggleChip(
            label: '동행글',
            selected: activeTab == MyPostsTab.mate,
            onTap: () => onChanged(MyPostsTab.mate),
          ),
          const SizedBox(width: 6),
          _PostsToggleChip(
            label: '게시글',
            selected: activeTab == MyPostsTab.board,
            onTap: () => onChanged(MyPostsTab.board),
          ),
        ],
      ),
    );
  }
}

class _PostsToggleChip extends StatelessWidget {
  const _PostsToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF3278) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: selected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MyBoardPostCard extends StatelessWidget {
  const _MyBoardPostCard({required this.post});

  final BoardPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => BoardDetailPage(post: post),
            ),
          );
          if (!context.mounted) return;
          await context.read<MyPostsViewModel>().refresh(MyPostsTab.board);
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
                  const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.white54),
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
  const _MyCompanionPostCard({required this.post});

  final CompanionPost post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CompanionDetailPage(post: post),
            ),
          );
          if (!context.mounted) return;
          await context.read<MyPostsViewModel>().refresh(MyPostsTab.mate);
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
                  const Icon(Icons.chat_bubble_outline,
                      size: 18, color: Colors.white54),
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
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('다시 시도'),
        ),
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
