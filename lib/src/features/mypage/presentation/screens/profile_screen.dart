import 'dart:math' as math;

import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectStoreProvider.notifier).loadProjects();
    });
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
                  label: '내 프로젝트',
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

class _ReportSummary extends ConsumerWidget {
  const _ReportSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStoreProvider);
    final stats = _ProjectStats.fromProjects(projectState.projects);
    final isLoading = projectState.isLoading && projectState.projects.isEmpty;

    final highestLevel = isLoading
        ? '불러오는 중'
        : stats.highestCompletedLevel ?? '기록 없음';
    final completedRoutes = isLoading ? '-' : '${stats.completedCount}개';
    final activeProjects = isLoading ? '-' : '${stats.ongoingCount}개';

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
            children: [
              _StatBlock(label: '최고 완등 레벨', value: highestLevel),
              const SizedBox(width: 12),
              _StatBlock(label: '완등한 루트 수', value: completedRoutes),
              const SizedBox(width: 12),
              _StatBlock(label: '진행중인 프로젝트', value: activeProjects),
            ],
          ),
        ),
        _CompletionChart(entries: stats.recentCompletions),
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

class _ProjectStats {
  const _ProjectStats({
    required this.highestCompletedLevel,
    required this.completedCount,
    required this.ongoingCount,
    required this.recentCompletions,
  });

  final String? highestCompletedLevel;
  final int completedCount;
  final int ongoingCount;
  final List<_ChartEntry> recentCompletions;

  factory _ProjectStats.fromProjects(List<ProjectModel> projects) {
    final completed = <ProjectModel>[];
    var ongoingCount = 0;

    for (final project in projects) {
      if (project.completed) {
        completed.add(project);
      } else {
        ongoingCount++;
      }
    }

    return _ProjectStats(
      highestCompletedLevel: _extractHighestLevel(completed),
      completedCount: completed.length,
      ongoingCount: ongoingCount,
      recentCompletions: _buildChartEntries(completed),
    );
  }
}

const int _chartEntryLimit = 10;
const int _maxLevelScore = 15;

String? _extractHighestLevel(List<ProjectModel> projects) {
  String? bestLevel;
  var bestScore = -1;

  for (final project in projects) {
    final rawLevel = project.routeInfo?.routeLevel ?? '';
    final level = rawLevel.replaceAll('+', '').trim();
    if (level.isEmpty) continue;

    final score = _levelScore(level);
    if (score > bestScore) {
      bestScore = score;
      bestLevel = level;
    }
  }

  return bestLevel;
}

final RegExp _routeLevelDigitPattern = RegExp(r'(\d+)');

int _levelScore(String level) {
  final normalized = level.trim().toUpperCase();
  int? maxNumber;

  for (final match in _routeLevelDigitPattern.allMatches(normalized)) {
    final value = int.tryParse(match.group(1)!);
    if (value == null) continue;
    if (maxNumber == null || value > maxNumber) {
      maxNumber = value;
    }
  }

  if (maxNumber != null) {
    return maxNumber;
  }

  if (normalized.contains('VB')) {
    return 0;
  }
  if (normalized.contains('초')) {
    return 1;
  }
  if (normalized.contains('중')) {
    return 2;
  }
  if (normalized.contains('상')) {
    return 3;
  }
  return -1;
}

List<_ChartEntry> _buildChartEntries(List<ProjectModel> projects) {
  if (projects.isEmpty) return _mockChartEntries();
  final sorted = List<ProjectModel>.from(projects)
    ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  if (sorted.length > _chartEntryLimit) {
    sorted.removeRange(0, sorted.length - _chartEntryLimit);
  }

  return sorted.map((project) {
    final rawLevel = project.routeInfo?.routeLevel ?? '';
    final level = rawLevel.replaceAll('+', '').trim();
    final score = math.max(_levelScore(level), 0);
    return _ChartEntry(
      date: project.updatedAt,
      levelLabel: level.isEmpty ? '정보 없음' : level,
      score: score,
    );
  }).toList();
}

List<_ChartEntry> _mockChartEntries() {
  final now = DateTime.now();
  final baseDate = DateTime(now.year, now.month, now.day);
  const mockLevels = <String>[
    'VB',
    'V1',
    'V2',
    'V3',
    'V4',
    'V5',
    'V6',
    'V7',
    'V8',
    'V9',
  ];
  final entries = List<_ChartEntry>.generate(mockLevels.length, (index) {
    final level = mockLevels[index];
    final offsetDays = (mockLevels.length - index) * 2;
    final date = baseDate.subtract(Duration(days: offsetDays));
    final score = math.max(_levelScore(level), (index % 4) + 1);
    return _ChartEntry(
      date: date,
      levelLabel: level,
      score: score,
    );
  });

  if (entries.isNotEmpty) {
    final duplicateDate = entries.last.date;
    entries.add(
      _ChartEntry(
        date: duplicateDate,
        levelLabel: 'V10',
        score: math.max(_levelScore('V10'), 8),
      ),
    );
  }

  return entries;
}

class _ChartEntry {
  const _ChartEntry({
    required this.date,
    required this.levelLabel,
    required this.score,
  });

  final DateTime date;
  final String levelLabel;
  final int score;

  String get dateLabel {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}

class _CompletionChart extends StatelessWidget {
  const _CompletionChart({required this.entries});

  final List<_ChartEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '완등 레벨 추이',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const _ChartEmptyState()
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _ChartBars(entries: entries)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartBars extends StatelessWidget {
  const _ChartBars({required this.entries});

  final List<_ChartEntry> entries;

  @override
  Widget build(BuildContext context) {
    final maxScore = entries.fold<int>(1, (prev, entry) {
      final value = math.max(entry.score, 0);
      return value > prev ? value : prev;
    });
    final scaleBase = math.max(_maxLevelScore, maxScore);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final normalized =
              scaleBase <= 0 ? 0.0 : entry.score / scaleBase.toDouble();
          final heightFactor = normalized.clamp(0.05, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              width: 44,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    entry.levelLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: heightFactor,
                        widthFactor: 0.32,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3278),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.dateLabel,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: const Text(
        '완등 기록이 아직 없어요.',
        style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
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
