import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/companion_post.dart';
import '../models/board_post.dart';
import '../widgets/companion_post_card.dart';
import '../widgets/board_post_card.dart';

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
            _CompanionTab(),
            _BoardTab(),
            _ChallengeTab(),
          ],
        ),
      ),
    );
  }
}

class _CompanionTab extends StatelessWidget {
  final List<CompanionPost> demoPosts = [
    CompanionPost(
      title: '주말 남양주 바윗길 같이 가실 분',
      meetingPlace: '경기도 남양주시',
      meetingDateLabel: '2025.07.29 (Fri)',
      authorNickname: 'rockgoer',
      commentCount: 12,
      viewCount: 245,
      createdAt: DateTime(2025, 7, 20, 10, 0),
    ),
    CompanionPost(
      title: '평일 저녁 도봉산 러닝 클라임',
      meetingPlace: '서울특별시 도봉구',
      meetingDateLabel: '2025.08.02 (Tue)',
      authorNickname: 'boulderBear',
      commentCount: 4,
      viewCount: 87,
      createdAt: DateTime(2025, 7, 21, 14, 30),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      itemCount: demoPosts.length,
      itemBuilder: (context, index) {
        return CompanionPostCard(post: demoPosts[index]);
      },
    );
  }
}

class _BoardTab extends StatelessWidget {
  final List<BoardPost> demoPosts = [
    BoardPost(
      title: '초보자를 위한 바위 신발 추천',
      authorNickname: 'stonecat',
      commentCount: 8,
      viewCount: 123,
      createdAt: DateTime(2025, 7, 22, 9, 15),
    ),
    BoardPost(
      title: '크럭스 구간에서의 몸의 균형 잡기',
      authorNickname: 'betaSeeker',
      commentCount: 3,
      viewCount: 64,
      createdAt: DateTime(2025, 7, 23, 16, 40),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      itemCount: demoPosts.length,
      itemBuilder: (context, index) {
        return BoardPostCard(post: demoPosts[index]);
      },
    );
  }
}

class _ChallengeTab extends StatelessWidget {
  const _ChallengeTab({super.key});

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
