import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/shared/widgets/avatar_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  _ProfileTab _currentTab = _ProfileTab.report;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _ProfileTab.values.length,
      vsync: this,
      initialIndex: _currentTab.index,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStoreProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        titleSpacing: 20,
        centerTitle: false,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(user: userState.user),
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFF3278),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            dividerColor: Colors.grey[800],
            labelStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: '기록'),
              Tab(text: '활동'),
              Tab(text: ''),
            ],
          ),
          const SizedBox(height: 20),
          switch (_currentTab) {
            _ProfileTab.report => const _ReportSummary(),
            _ProfileTab.activity => _ProfileMenuSection(
              items: [
                _ProfileMenuItemData(
                  label: '프로젝트',
                  onTap: () => _openMyRoutes(context),
                ),
                _ProfileMenuItemData(
                  label: '내 게시글',
                  onTap: () => _openMyPosts(context),
                ),
                _ProfileMenuItemData(
                  label: '내 댓글',
                  onTap: () => _openMyComments(context),
                ),
                _ProfileMenuItemData(
                  label: '좋아요',
                  onTap: () => _openMyLikes(context),
                ),
              ],
            ),
            _ProfileTab.placeholder => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  void _openMyRoutes(BuildContext context) {
    context.push(AppRoutes.myRoutes);
  }

  void _openMyPosts(BuildContext context) {
    context.push(AppRoutes.myPosts);
  }

  void _openMyLikes(BuildContext context) {
    context.push(AppRoutes.myLikes);
  }

  void _openMyComments(BuildContext context) {
    context.push(AppRoutes.myComments);
  }

  void _openSettings(BuildContext context) {
    context.push(AppRoutes.settings);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final newTab = _ProfileTab.values[_tabController.index];
    if (newTab != _currentTab) {
      setState(() {
        _currentTab = newTab;
      });
    }
  }
}

enum _ProfileTab { report, activity, placeholder }

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 68,
          height: 68,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[400],
            border: Border.all(color: Colors.grey[500]!, width: 1),
          ),
          child: AvatarPlaceholder(
            size: 64,
            imageUrl: user?.profileImageUrl,
            backgroundColor: Colors.grey[300] ?? const Color(0xFFE0E0E0),
            iconColor: Colors.grey[600] ?? Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.nickname ?? '로그인 필요',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => context.push(AppRoutes.profileEdit),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '프로필 수정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Color(0xFFFF3278),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최근 리포트',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: const [
              _StatBlock(label: '이번 달 등반 횟수', value: '4회'),
              SizedBox(width: 12),
              _StatBlock(label: '완등한 루트', value: '12개'),
              SizedBox(width: 12),
              _StatBlock(label: '작성한 댓글', value: '7개'),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.items});

  final List<_ProfileMenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Column(
              children: [
                _ProfileMenuRow(data: item),
                if (item != items.last)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({required this.data});

  final _ProfileMenuItemData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Text(
              data.label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItemData {
  _ProfileMenuItemData({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}
