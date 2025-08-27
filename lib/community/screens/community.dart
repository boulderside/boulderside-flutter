import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/companion_post.dart';
import '../models/board_post.dart';
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
  
  final List<CompanionPost> demoPosts = [
    CompanionPost(
      title: '주말 남양주 바윗길 같이 가실 분',
      meetingPlace: '경기도 남양주시',
      meetingDateLabel: '2025.07.29 (Fri)',
      authorNickname: 'rockgoer',
      commentCount: 12,
      viewCount: 245,
      createdAt: DateTime(2025, 7, 20, 10, 0),
      content: '안녕하세요! 주말에 남양주 바윗길 함께 가실 분을 찾습니다. 초보자도 환영해요.',
    ),
    CompanionPost(
      title: '평일 저녁 도봉산 러닝 클라임',
      meetingPlace: '서울특별시 도봉구',
      meetingDateLabel: '2025.08.02 (Tue)',
      authorNickname: 'boulderBear',
      commentCount: 4,
      viewCount: 87,
      createdAt: DateTime(2025, 7, 21, 14, 30),
      content: '퇴근 후 가볍게 러닝하고 바위 몇 개 타보실 분!',
    ),
  ];

  void _changeSort(CompanionPostSortOption sort) {
    if (_currentSort != sort) {
      setState(() {
        _currentSort = sort;
      });
      // TODO: Implement actual sorting logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        ...demoPosts.map((post) => CompanionPostCard(post: post)),
      ],
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
  
  final List<BoardPost> demoPosts = [
    BoardPost(
      title: '초보자를 위한 바위 신발 추천',
      authorNickname: 'stonecat',
      commentCount: 8,
      viewCount: 123,
      createdAt: DateTime(2025, 7, 22, 9, 15),
      content: '입문자를 위한 신발 추천과 사이즈 팁을 정리해봤어요.',
    ),
    BoardPost(
      title: '크럭스 구간에서의 몸의 균형 잡기',
      authorNickname: 'betaSeeker',
      commentCount: 3,
      viewCount: 64,
      createdAt: DateTime(2025, 7, 23, 16, 40),
      content: '크럭스에서 밸런스를 유지하는 법에 대해 공유합니다.',
    ),
  ];

  void _changeSort(GeneralPostSortOption sort) {
    if (_currentSort != sort) {
      setState(() {
        _currentSort = sort;
      });
      // TODO: Implement actual sorting logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        ...demoPosts.map((post) => BoardPostCard(post: post)),
      ],
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
