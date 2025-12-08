import 'package:boulderside_flutter/src/features/community/application/board_post_store.dart';
import 'package:boulderside_flutter/src/features/community/application/companion_post_store.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/board_post_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/community_intro_text.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_sort_option.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/general_post_sort_option.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/post_skeleton_list.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/widgets/sort_option_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  static String routeName = 'Community';
  static String routePath = '/community';

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final GlobalKey<_CompanionTabState> _companionTabKey =
      GlobalKey<_CompanionTabState>();
  final GlobalKey<_BoardTabState> _boardTabKey = GlobalKey<_BoardTabState>();

  Future<void> _navigateToPostCreate(int tabIndex) async {
    if (tabIndex == 0) {
      final response = await context.push<MatePostResponse>(
        AppRoutes.communityCompanionCreate,
      );

      if (!mounted || response == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('동행 글이 생성되었습니다.')));
      await context.push(
        AppRoutes.communityCompanionDetail,
        extra: response.toCompanionPost(),
      );
      _companionTabKey.currentState?._refreshList();
      return;
    }

    if (tabIndex == 1) {
      final response = await context.push<BoardPostResponse>(
        AppRoutes.communityBoardCreate,
      );

      if (!mounted || response == null) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시판 글이 생성되었습니다.')));
      await context.push(
        AppRoutes.communityBoardDetail,
        extra: response.toBoardPost(),
      );
      _boardTabKey.currentState?._refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          automaticallyImplyLeading: false,
          title: const Text(
            '커뮤니티',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => context.push(AppRoutes.search),
            ),
          ],
          centerTitle: false,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: 'Pretendard',
              letterSpacing: 0.0,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            indicatorColor: Color(0xFFFF3278),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: '동행'),
              Tab(text: '게시판'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CompanionTab(key: _companionTabKey),
            _BoardTab(key: _boardTabKey),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final controller = DefaultTabController.of(context);
            return FloatingActionButton(
              backgroundColor: const Color(0xFFFF3278),
              foregroundColor: Colors.white,
              tooltip: '새 글 쓰기',
              onPressed: () {
                _navigateToPostCreate(controller.index);
              },
              child: const Icon(CupertinoIcons.pencil),
            );
          },
        ),
      ),
    );
  }
}

class _CompanionTab extends rp.ConsumerStatefulWidget {
  const _CompanionTab({super.key});

  @override
  rp.ConsumerState<_CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends rp.ConsumerState<_CompanionTab>
    with InfiniteScrollMixin<_CompanionTab> {
  CompanionPostSortOption _currentSort = CompanionPostSortOption.latest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companionPostStoreProvider.notifier).loadInitial(_currentSort);
    });
  }

  @override
  bool get canLoadMore =>
      ref.read(companionFeedProvider(_currentSort)).hasNext &&
      !ref.read(companionFeedProvider(_currentSort)).isLoadingMore;

  @override
  Future<void> onNearBottom() async {
    await ref.read(companionPostStoreProvider.notifier).loadMore(_currentSort);
  }

  void _refreshList() {
    ref.read(companionPostStoreProvider.notifier).refresh(_currentSort);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(companionFeedProvider(_currentSort));
    final notifier = ref.read(companionPostStoreProvider.notifier);

    if (feed.isInitialLoading) {
      return const PostSkeletonList();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(_currentSort),
      backgroundColor: const Color(0xFF262A34),
      color: const Color(0xFFFF3278),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const CommunityIntroText(),
          SortOptionBar<CompanionPostSortOption>(
            options: const [
              SortOption(label: '최신순', value: CompanionPostSortOption.latest),
              SortOption(
                label: '조회수순',
                value: CompanionPostSortOption.mostViewed,
              ),
              SortOption(
                label: '동행날짜순',
                value: CompanionPostSortOption.companionDate,
              ),
            ],
            selectedValue: _currentSort,
            onSelected: (sort) {
              if (_currentSort == sort) return;
              setState(() {
                _currentSort = sort;
              });
              notifier.loadInitial(sort);
            },
          ),
          if (feed.errorMessage != null && feed.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                feed.errorMessage!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ...feed.items.map((post) => CompanionPostCard(post: post)),
          if (feed.isLoadingMore)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
        ],
      ),
    );
  }
}

class _BoardTab extends rp.ConsumerStatefulWidget {
  const _BoardTab({super.key});

  @override
  rp.ConsumerState<_BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends rp.ConsumerState<_BoardTab>
    with InfiniteScrollMixin<_BoardTab> {
  GeneralPostSortOption _currentSort = GeneralPostSortOption.latest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boardPostStoreProvider.notifier).loadInitial(_currentSort);
    });
  }

  @override
  bool get canLoadMore {
    final feed = ref.read(boardPostFeedProvider(_currentSort));
    return feed.hasNext && !feed.isLoadingMore;
  }

  @override
  Future<void> onNearBottom() async {
    await ref.read(boardPostStoreProvider.notifier).loadMore(_currentSort);
  }

  void _refreshList() {
    ref.read(boardPostStoreProvider.notifier).refresh(_currentSort);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(boardPostFeedProvider(_currentSort));
    final notifier = ref.read(boardPostStoreProvider.notifier);

    if (feed.isInitialLoading) {
      return const PostSkeletonList();
    }

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(_currentSort),
      backgroundColor: const Color(0xFF262A34),
      color: const Color(0xFFFF3278),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const CommunityIntroText(),
          SortOptionBar<GeneralPostSortOption>(
            options: const [
              SortOption(label: '최신순', value: GeneralPostSortOption.latest),
              SortOption(
                label: '조회수순',
                value: GeneralPostSortOption.mostViewed,
              ),
            ],
            selectedValue: _currentSort,
            onSelected: (sort) {
              if (_currentSort == sort) return;
              setState(() {
                _currentSort = sort;
              });
              notifier.loadInitial(sort);
            },
          ),
          if (feed.errorMessage != null && feed.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                feed.errorMessage!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ...feed.items.map(
            (post) => BoardPostCard(
              post: post,
              onRefresh: () => notifier.refresh(_currentSort),
            ),
          ),
          if (feed.isLoadingMore)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
        ],
      ),
    );
  }
}
