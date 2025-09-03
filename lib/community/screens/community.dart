import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/companion_post.dart';
import '../models/board_post.dart';
import '../models/post_models.dart';
import '../services/post_service.dart';
import '../widgets/companion_post_card.dart';
import '../widgets/board_post_card.dart';
import '../widgets/community_intro_text.dart';
import '../widgets/companion_post_sort_option.dart';
import '../widgets/general_post_sort_option.dart';
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
            const _CompanionTab(),
            const _BoardTab(),
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
                final tabIndex = controller.index;
                if (tabIndex == 0) {
                  Navigator.pushNamed(context, '/community/companion/create');
                } else if (tabIndex == 1) {
                  Navigator.pushNamed(context, '/community/board/create');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('챌린지 글쓰기는 곧 제공 예정입니다.')),
                  );
                }
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
  const _CompanionTab();

  @override
  State<_CompanionTab> createState() => _CompanionTabState();
}

class _CompanionTabState extends State<_CompanionTab> {
  CompanionPostSortOption _currentSort = CompanionPostSortOption.latest;
  final PostService _postService = PostService();
  
  List<CompanionPost> _posts = [];
  bool _isLoading = true;
  int? _nextCursor;
  String? _nextSubCursor;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _nextCursor = null;
        _nextSubCursor = null;
        _posts = [];
      });
    }

    try {
      final response = await _postService.getPostPage(
        cursor: _nextCursor,
        subCursor: _nextSubCursor,
        size: 5,
        postType: PostType.mate,
        postSortType: _getPostSortType(_currentSort),
      );

      setState(() {
        _posts = refresh 
            ? response.content.map((post) => post.toCompanionPost()).toList()
            : [..._posts, ...response.content.map((post) => post.toCompanionPost())];
        _nextCursor = response.nextCursor;
        _nextSubCursor = response.nextSubCursor;
        _hasNext = response.hasNext;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글을 불러오는데 실패했습니다: $error')),
        );
      }
    }
  }

  PostSortType _getPostSortType(CompanionPostSortOption sort) {
    switch (sort) {
      case CompanionPostSortOption.latest:
        return PostSortType.latestCreated;
      case CompanionPostSortOption.mostViewed:
        return PostSortType.mostViewed;
      case CompanionPostSortOption.companionDate:
        return PostSortType.nearestMeetingDate;
    }
  }

  void _changeSort(CompanionPostSortOption sort) {
    if (_currentSort != sort) {
      setState(() {
        _currentSort = sort;
      });
      _loadPosts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadPosts(refresh: true),
      child: ListView(
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
                selected: _currentSort == CompanionPostSortOption.latest,
                onTap: () => _changeSort(CompanionPostSortOption.latest),
              ),
              const SizedBox(width: 10),
              SortButton(
                text: CompanionPostSortOption.mostViewed.displayText,
                selected: _currentSort == CompanionPostSortOption.mostViewed,
                onTap: () => _changeSort(CompanionPostSortOption.mostViewed),
              ),
              const SizedBox(width: 10),
              SortButton(
                text: CompanionPostSortOption.companionDate.displayText,
                selected: _currentSort == CompanionPostSortOption.companionDate,
                onTap: () => _changeSort(CompanionPostSortOption.companionDate),
              ),
            ].divide(const SizedBox(width: 0)),
          ),
        ),
        
        // 동행 포스트 리스트
        if (_isLoading && _posts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            ),
          )
        else if (_posts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                '게시글이 없습니다.',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          )
        else
          ..._posts.map((post) => CompanionPostCard(post: post)),
        
        // Load more button
        if (_hasNext && !_isLoading)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () => _loadPosts(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  foregroundColor: Colors.white,
                ),
                child: const Text('더 보기'),
              ),
            ),
          ),
        
        if (_isLoading && _posts.isNotEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            ),
          ),
      ],
      ),
    );
  }
}

class _BoardTab extends StatefulWidget {
  const _BoardTab();

  @override
  State<_BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<_BoardTab> {
  GeneralPostSortOption _currentSort = GeneralPostSortOption.latest;
  final PostService _postService = PostService();
  
  List<BoardPost> _posts = [];
  bool _isLoading = true;
  int? _nextCursor;
  String? _nextSubCursor;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _nextCursor = null;
        _nextSubCursor = null;
        _posts = [];
      });
    }

    try {
      final response = await _postService.getPostPage(
        cursor: _nextCursor,
        subCursor: _nextSubCursor,
        size: 5,
        postType: PostType.board,
        postSortType: _getPostSortType(_currentSort),
      );

      setState(() {
        _posts = refresh 
            ? response.content.map((post) => post.toBoardPost()).toList()
            : [..._posts, ...response.content.map((post) => post.toBoardPost())];
        _nextCursor = response.nextCursor;
        _nextSubCursor = response.nextSubCursor;
        _hasNext = response.hasNext;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시글을 불러오는데 실패했습니다: $error')),
        );
      }
    }
  }

  PostSortType _getPostSortType(GeneralPostSortOption sort) {
    switch (sort) {
      case GeneralPostSortOption.latest:
        return PostSortType.latestCreated;
      case GeneralPostSortOption.mostViewed:
        return PostSortType.mostViewed;
    }
  }

  void _changeSort(GeneralPostSortOption sort) {
    if (_currentSort != sort) {
      setState(() {
        _currentSort = sort;
      });
      _loadPosts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _loadPosts(refresh: true),
      child: ListView(
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
                  selected: _currentSort == GeneralPostSortOption.latest,
                  onTap: () => _changeSort(GeneralPostSortOption.latest),
                ),
                const SizedBox(width: 10),
                SortButton(
                  text: GeneralPostSortOption.mostViewed.displayText,
                  selected: _currentSort == GeneralPostSortOption.mostViewed,
                  onTap: () => _changeSort(GeneralPostSortOption.mostViewed),
                ),
              ].divide(const SizedBox(width: 0)),
            ),
          ),
          
          // 게시판 포스트 리스트
          if (_isLoading && _posts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            )
          else if (_posts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  '게시글이 없습니다.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            )
          else
            ..._posts.map((post) => BoardPostCard(post: post)),
          
          // Load more button
          if (_hasNext && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _loadPosts(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('더 보기'),
                ),
              ),
            ),
          
          if (_isLoading && _posts.isNotEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
        ],
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
