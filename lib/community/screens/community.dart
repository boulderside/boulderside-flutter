import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../viewmodels/companion_post_list_view_model.dart';
import '../viewmodels/board_post_list_view_model.dart';
import '../services/post_service.dart';
import '../models/post_models.dart';
import '../widgets/companion_post_card.dart';
import '../widgets/board_post_card.dart';
import '../widgets/community_intro_text.dart';
import '../widgets/companion_post_sort_option.dart';
import '../widgets/general_post_sort_option.dart';
import '../widgets/post_form.dart';
import '../../home/widgets/sort_button.dart';
import '../../utils/widget_extensions.dart';

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

  void _navigateToPostCreate(BuildContext context, int tabIndex) {
    if (tabIndex == 0) {
      // Companion post
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostForm(
            postType: PostType.mate,
            onSuccess: (response) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('동행 글이 생성되었습니다.')),
              );
              // Refresh the companion list
              _companionTabKey.currentState?._refreshList();
            },
          ),
        ),
      );
    } else if (tabIndex == 1) {
      // Board post
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostForm(
            postType: PostType.board,
            onSuccess: (response) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('게시판 글이 생성되었습니다.')),
              );
              // Refresh the board list
              _boardTabKey.currentState?._refreshList();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('챌린지 글쓰기는 곧 제공 예정입니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(text: '챌린지'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CompanionTab(key: _companionTabKey),
            _BoardTab(key: _boardTabKey),
            const _ChallengeTab(),
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
      create: (_) => CompanionPostListViewModel(PostService())..loadInitial(),
      child: Consumer<CompanionPostListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;
          
          // 최초 데이터 로드 (목록 비어있고 로딩 중)
          if (vm.isLoading && vm.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            );
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
      create: (_) => BoardPostListViewModel(PostService())..loadInitial(),
      child: Consumer<BoardPostListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;
          
          // 최초 데이터 로드 (목록 비어있고 로딩 중)
          if (vm.isLoading && vm.posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            );
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

class _ChallengeTab extends StatelessWidget {
  const _ChallengeTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '이 기능은 곧 제공될 예정입니다.',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
