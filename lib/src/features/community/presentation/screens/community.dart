import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/viewmodels/board_post_list_view_model.dart';
import 'package:boulderside_flutter/src/features/community/presentation/viewmodels/companion_post_list_view_model.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/board_post_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/board_post_form_page.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/community_intro_text.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_card.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_form_page.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_sort_option.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/general_post_sort_option.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/post_skeleton_list.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/sort_button.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  static String routeName = 'Community';
  static String routePath = '/community';

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final GlobalKey<_CompanionTabState> _companionTabKey = GlobalKey<_CompanionTabState>();
  final GlobalKey<_BoardTabState> _boardTabKey = GlobalKey<_BoardTabState>();

  Future<void> _navigateToPostCreate(BuildContext context, int tabIndex) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (tabIndex == 0) {
      final response = await navigator.push<MatePostResponse>(
        MaterialPageRoute(
          builder: (context) => CompanionPostFormPage(
            onSuccess: (_) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('동행 글이 생성되었습니다.'),
                ),
              );
            },
          ),
        ),
      );

      if (!mounted || response == null) return;
      await navigator.pushNamed(
        AppRoutes.communityCompanionDetail,
        arguments: response.toCompanionPost(),
      );
      _companionTabKey.currentState?._refreshList();
      return;
    }

    if (tabIndex == 1) {
      final response = await navigator.push<BoardPostResponse>(
        MaterialPageRoute(
          builder: (context) => BoardPostFormPage(
            onSuccess: (_) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('게시판 글이 생성되었습니다.'),
                ),
              );
            },
          ),
        ),
      );

      if (!mounted || response == null) return;
      await navigator.pushNamed(
        AppRoutes.communityBoardDetail,
        arguments: response.toBoardPost(),
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
              icon: const Icon(CupertinoIcons.search, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.pushNamed(context, '/search');
              },
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
                _navigateToPostCreate(context, controller.index);
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

class _CompanionTabState extends State<_CompanionTab> {
  final ScrollController _scrollController = ScrollController();
  CompanionPostListViewModel? _viewModel;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_viewModel == null) return;
    
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !_viewModel!.isLoading &&
        _viewModel!.hasNext) {
      _viewModel!.loadMore();
    }
  }
  
  void _refreshList() {
    _viewModel?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanionPostListViewModel(MatePostService())
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
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 커뮤니티 소개 텍스트
                const CommunityIntroText(),
                
                // 정렬 버튼
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
                  child: Row(
                    children: [
                      SortButton(
                        text: CompanionPostSortOption.latest.displayText,
                        selected: vm.currentSort == CompanionPostSortOption.latest,
                        onTap: () => vm.changeSort(CompanionPostSortOption.latest),
                      ),
                      const SizedBox(width: 10),
                      SortButton(
                        text: CompanionPostSortOption.mostViewed.displayText,
                        selected: vm.currentSort == CompanionPostSortOption.mostViewed,
                        onTap: () => vm.changeSort(CompanionPostSortOption.mostViewed),
                      ),
                      const SizedBox(width: 10),
                      SortButton(
                        text: CompanionPostSortOption.companionDate.displayText,
                        selected: vm.currentSort == CompanionPostSortOption.companionDate,
                        onTap: () => vm.changeSort(CompanionPostSortOption.companionDate),
                      ),
                    ].divide(const SizedBox(width: 0)),
                  ),
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

class _BoardTabState extends State<_BoardTab> {
  final ScrollController _scrollController = ScrollController();
  BoardPostListViewModel? _viewModel;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_viewModel == null) return;
    
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !_viewModel!.isLoading &&
        _viewModel!.hasNext) {
      _viewModel!.loadMore();
    }
  }
  
  void _refreshList() {
    _viewModel?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoardPostListViewModel(BoardPostService())
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
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 커뮤니티 소개 텍스트
                const CommunityIntroText(),
                
                // 정렬 버튼
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
                  child: Row(
                    children: [
                      SortButton(
                        text: GeneralPostSortOption.latest.displayText,
                        selected: vm.currentSort == GeneralPostSortOption.latest,
                        onTap: () => vm.changeSort(GeneralPostSortOption.latest),
                      ),
                      const SizedBox(width: 10),
                      SortButton(
                        text: GeneralPostSortOption.mostViewed.displayText,
                        selected: vm.currentSort == GeneralPostSortOption.mostViewed,
                        onTap: () => vm.changeSort(GeneralPostSortOption.mostViewed),
                      ),
                    ].divide(const SizedBox(width: 0)),
                  ),
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
