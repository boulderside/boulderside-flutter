import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/viewmodels/board_post_list_view_model.dart';
import 'package:boulderside_flutter/src/features/community/presentation/viewmodels/companion_post_list_view_model.dart';
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
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

class _CompanionTab extends StatefulWidget {
  const _CompanionTab({super.key});

  @override
  State<_CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends State<_CompanionTab>
    with InfiniteScrollMixin<_CompanionTab> {
  CompanionPostListViewModel? _viewModel;
  bool _initialLoaded = false;

  @override
  bool get canLoadMore =>
      _viewModel != null && !_viewModel!.isLoading && _viewModel!.hasNext;

  @override
  Future<void> onNearBottom() async {
    await _viewModel?.loadMore();
  }

  void _refreshList() {
    _viewModel?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          CompanionPostListViewModel(context.read<MatePostService>())
            ..loadInitial().then((_) {
              if (mounted) {
                setState(() => _initialLoaded = true);
              }
            }),
      child: Consumer<CompanionPostListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;

          if (!_initialLoaded) {
            return const PostSkeletonList();
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 커뮤니티 소개 텍스트
                const CommunityIntroText(),

                // 정렬 버튼
                SortOptionBar<CompanionPostSortOption>(
                  options: const [
                    SortOption(
                      label: '최신순',
                      value: CompanionPostSortOption.latest,
                    ),
                    SortOption(
                      label: '조회수순',
                      value: CompanionPostSortOption.mostViewed,
                    ),
                    SortOption(
                      label: '동행날짜순',
                      value: CompanionPostSortOption.companionDate,
                    ),
                  ],
                  selectedValue: vm.currentSort,
                  onSelected: vm.changeSort,
                ),

                // 동행 포스트 리스트
                ...vm.posts.map((post) => CompanionPostCard(post: post)),

                // 로딩 인디케이터
                if (vm.isLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoardTab extends StatefulWidget {
  const _BoardTab({super.key});

  @override
  State<_BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<_BoardTab>
    with InfiniteScrollMixin<_BoardTab> {
  BoardPostListViewModel? _viewModel;
  bool _initialLoaded = false;

  @override
  bool get canLoadMore =>
      _viewModel != null && !_viewModel!.isLoading && _viewModel!.hasNext;

  @override
  Future<void> onNearBottom() async {
    await _viewModel?.loadMore();
  }

  void _refreshList() {
    _viewModel?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          BoardPostListViewModel(context.read<BoardPostService>())
            ..loadInitial().then((_) {
              if (mounted) {
                setState(() => _initialLoaded = true);
              }
            }),
      child: Consumer<BoardPostListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;

          // 최초 데이터 로드 (목록 비어있고 로딩 중)
          if (!_initialLoaded) {
            return const PostSkeletonList();
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 커뮤니티 소개 텍스트
                const CommunityIntroText(),

                // 정렬 버튼
                SortOptionBar<GeneralPostSortOption>(
                  options: const [
                    SortOption(
                      label: '최신순',
                      value: GeneralPostSortOption.latest,
                    ),
                    SortOption(
                      label: '조회수순',
                      value: GeneralPostSortOption.mostViewed,
                    ),
                  ],
                  selectedValue: vm.currentSort,
                  onSelected: vm.changeSort,
                ),

                // 게시판 포스트 리스트
                ...vm.posts.map((post) => BoardPostCard(post: post)),

                // 로딩 인디케이터
                if (vm.isLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
