import 'dart:math' as math;

import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_summary_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completion_providers.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_summary_response.dart';
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
            _ProfileTab.report => _ReportSummary(
              onCompletedTap: () => _openCompletedRoutes(context),
              onActiveTap: () => _openActiveProjects(context),
            ),
            _ProfileTab.activity => _ProfileMenuSection(
              items: [
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
                _ProfileMenuItemData(
                  label: '내 풀이',
                  onTap: () => _openMyInstagrams(context),
                ),
              ],
            ),
            _ProfileTab.placeholder => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }

  void _openCompletedRoutes(BuildContext context) {
    context.push(AppRoutes.completedRoutes);
  }

  void _openActiveProjects(BuildContext context) {
    context.push(AppRoutes.myRoutes, extra: ProjectFilter.trying);
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

  void _openMyInstagrams(BuildContext context) {
    context.push(AppRoutes.myInstagrams);
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
  const _ReportSummary({
    required this.onCompletedTap,
    required this.onActiveTap,
  });

  final VoidCallback onCompletedTap;
  final VoidCallback onActiveTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(projectSummaryProvider);

    return summaryAsync.when(
      data: (summary) => _ReportSummaryContent(
        highestLevel: summary.highestCompletedLevel,
        completedCount: summary.completedRouteCount,
        activeCount: summary.ongoingProjectCount,
        entries: _buildChartEntries(summary.completedRoutes),
        completionIdsByLevel: summary.completionIdsByLevel,
        onCompletedTap: onCompletedTap,
        onActiveTap: onActiveTap,
      ),
      loading: () => _ReportSummaryContent(
        highestLevel: null,
        completedCount: null,
        activeCount: null,
        entries: const <_ChartEntry>[],
        completionIdsByLevel: const {},
        onCompletedTap: onCompletedTap,
        onActiveTap: onActiveTap,
        isLoading: true,
      ),
      error: (error, stackTrace) => _ReportSummaryContent(
        highestLevel: null,
        completedCount: null,
        activeCount: null,
        entries: const <_ChartEntry>[],
        completionIdsByLevel: const {},
        onCompletedTap: onCompletedTap,
        onActiveTap: onActiveTap,
        errorMessage: '최근 리포트를 불러오지 못했어요.',
      ),
    );
  }
}

class _ReportSummaryContent extends StatefulWidget {
  const _ReportSummaryContent({
    required this.highestLevel,
    required this.completedCount,
    required this.activeCount,
    required this.entries, // Trend entries
    required this.completionIdsByLevel, // Difficulty chart data
    required this.onCompletedTap,
    required this.onActiveTap,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? highestLevel;
  final int? completedCount;
  final int? activeCount;
  final List<_ChartEntry> entries;
  final Map<String, List<int>> completionIdsByLevel;
  final VoidCallback onCompletedTap;
  final VoidCallback onActiveTap;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<_ReportSummaryContent> createState() => _ReportSummaryContentState();
}

enum _ChartType { calendar, difficulty }

class _ReportSummaryContentState extends State<_ReportSummaryContent> {
  _ChartType _selectedChartType = _ChartType.difficulty;
  String? _selectedLevel;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final highestLevelLabel = widget.isLoading
        ? '불러오는 중'
        : (() {
            final raw = (widget.highestLevel ?? '').trim();
            final normalized = raw.replaceAll('+', '').toUpperCase();
            return normalized.isNotEmpty ? normalized : '기록 없음';
          })();
    final completedValue = widget.completedCount ?? 0;
    final activeValue = widget.activeCount ?? 0;
    final completedLabel = widget.isLoading ? '-' : '$completedValue개';
    final activeLabel = widget.isLoading ? '-' : '$activeValue개';

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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _StatBlock(label: '최고 완등 레벨', value: highestLevelLabel),
              const SizedBox(width: 12),
              _StatBlock(
                label: '완등한 루트 수',
                value: completedLabel,
                onTap: widget.isLoading ? null : widget.onCompletedTap,
                showChevron: true,
              ),
              const SizedBox(width: 12),
              _StatBlock(
                label: '진행중인 프로젝트',
                value: activeLabel,
                onTap: widget.isLoading ? null : widget.onActiveTap,
                showChevron: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _StatsChartSection(
          chartType: _selectedChartType,
          onTypeChanged: (type) {
            setState(() {
              _selectedChartType = type;
              if (type == _ChartType.calendar) {
                final now = DateTime.now();
                _selectedDate = DateTime(now.year, now.month, now.day);
                _selectedLevel = null;
              } else {
                // Reset both when switching back to difficulty
                _selectedLevel = null;
                _selectedDate = null;
              }
            });
          },
          onLevelSelected: (level) {
            setState(() {
              _selectedLevel = _selectedLevel == level ? null : level;
              _selectedDate = null;
            });
          },
          onDateSelected: (date) {
            setState(() {
              if (_selectedDate == date) {
                _selectedDate = null;
              } else {
                _selectedDate = date;
              }
              _selectedLevel = null;
            });
          },
          selectedDate: _selectedDate,
          calendarEntries: widget.entries,
          difficultyEntries: _buildDifficultyChartEntries(
            widget.completionIdsByLevel,
          ),
          isLoading: widget.isLoading,
        ),
        if (_selectedChartType == _ChartType.difficulty &&
            _selectedLevel == null) ...[
          const SizedBox(height: 32),
          const Center(
            child: Text(
              '막대를 눌러 난이도별 완등 기록을 확인하세요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white38,
                fontSize: 15,
              ),
            ),
          ),
        ] else if (_selectedLevel != null) ...[
          const SizedBox(height: 24),
          _CompletionList(level: _selectedLevel!),
        ] else if (_selectedDate != null) ...[
          const SizedBox(height: 24),
          _DateCompletionList(date: _selectedDate!),
        ],
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorMessage!,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ],
    );
  }

  List<_DifficultyChartEntry> _buildDifficultyChartEntries(
    Map<String, List<int>> completionIdsByLevel,
  ) {
    if (completionIdsByLevel.isEmpty) return const [];

    final entries = completionIdsByLevel.entries.map((e) {
      final level = e.key.replaceAll('+', '').trim();
      return _DifficultyChartEntry(
        levelLabel: level.isNotEmpty ? level : '정보 없음',
        count: e.value.length,
        score: _levelScore(level),
      );
    }).toList();

    // Sort by difficulty level
    entries.sort((a, b) => a.score.compareTo(b.score));

    return entries;
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    this.onTap,
    this.showChevron = true,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onTap != null && showChevron)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: onTap == null
          ? child
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            ),
    );
  }
}

const int _chartEntryLimit = 10;

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

List<_ChartEntry> _buildChartEntries(List<CompletedRouteCount> routes) {
  if (routes.isEmpty) return const <_ChartEntry>[];
  final sorted = List<CompletedRouteCount>.from(routes)
    ..sort((a, b) => a.completedDate.compareTo(b.completedDate));

  if (sorted.length > _chartEntryLimit) {
    sorted.removeRange(0, sorted.length - _chartEntryLimit);
  }

  return sorted.map((route) {
    return _ChartEntry(
      date: route.completedDate,
      levelLabel: route.cumulativeCount.toString(),
      score: route.cumulativeCount,
    );
  }).toList();
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

class _DifficultyChartEntry {
  const _DifficultyChartEntry({
    required this.levelLabel,
    required this.count,
    required this.score,
  });

  final String levelLabel;
  final int count;
  final int score;
}

class _StatsChartSection extends StatelessWidget {
  const _StatsChartSection({
    required this.chartType,
    required this.onTypeChanged,
    required this.onLevelSelected,
    this.onDateSelected,
    this.selectedDate,
    required this.calendarEntries,
    required this.difficultyEntries,
    this.isLoading = false,
  });

  final _ChartType chartType;
  final ValueChanged<_ChartType> onTypeChanged;
  final ValueChanged<String> onLevelSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? selectedDate;
  final List<_ChartEntry> calendarEntries;
  final List<_DifficultyChartEntry> difficultyEntries;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDifficultyEmpty = difficultyEntries.isEmpty;
    final Widget chartChild;

    if (chartType == _ChartType.difficulty && isDifficultyEmpty) {
      chartChild = isLoading
          ? const _ChartLoadingState()
          : const _ChartEmptyState();
    } else if (chartType == _ChartType.calendar) {
      if (isLoading) {
        chartChild = const _ChartLoadingState();
      } else {
        chartChild = SizedBox(
          height: 280,
          child: _CompletionCalendar(
            entries: calendarEntries,
            onDateSelected: onDateSelected,
            selectedDate: selectedDate,
          ),
        );
      }
    } else {
      chartChild = SizedBox(
        height: 190,
        child: _DifficultyChartBars(
          entries: difficultyEntries,
          onLevelSelected: onLevelSelected,
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '완등 분석',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            _ChartToggle(selectedType: chartType, onTypeChanged: onTypeChanged),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: chartChild,
        ),
      ],
    );
  }
}

class _ChartToggle extends StatelessWidget {
  const _ChartToggle({required this.selectedType, required this.onTypeChanged});

  final _ChartType selectedType;
  final ValueChanged<_ChartType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: '난이도별',
            isSelected: selectedType == _ChartType.difficulty,
            onTap: () => onTypeChanged(_ChartType.difficulty),
          ),
          const SizedBox(width: 4),
          _ToggleButton(
            label: '날짜별',
            isSelected: selectedType == _ChartType.calendar,
            onTap: () => onTypeChanged(_ChartType.calendar),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF3278) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _CompletionCalendar extends StatefulWidget {
  const _CompletionCalendar({
    required this.entries,
    this.onDateSelected,
    this.selectedDate,
  });

  final List<_ChartEntry> entries;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? selectedDate;

  @override
  State<_CompletionCalendar> createState() => _CompletionCalendarState();
}

class _CompletionCalendarState extends State<_CompletionCalendar> {
  late DateTime _focusedDate;
  late Set<int> _completionDays;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _updateCompletionDays();
  }

  @override
  void didUpdateWidget(covariant _CompletionCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _updateCompletionDays();
    }
  }

  void _updateCompletionDays() {
    _completionDays = widget.entries
        .where(
          (e) =>
              e.date.year == _focusedDate.year &&
              e.date.month == _focusedDate.month,
        )
        .map((e) => e.date.day)
        .toSet();
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);
      _updateCompletionDays();
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDate.year,
      _focusedDate.month,
    );
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0=Sun, 6=Sat

    const weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              '${_focusedDate.year}년 ${_focusedDate.month}월',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: _isNextMonthFuture()
                  ? const Icon(Icons.chevron_right, color: Colors.white24)
                  : const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: _isNextMonthFuture() ? null : () => _changeMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Weekday Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar Grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 42, // 6 weeks * 7 days
            itemBuilder: (context, index) {
              final dayOffset = index - firstWeekday;
              final day = dayOffset + 1;

              if (day < 1 || day > daysInMonth) {
                return const SizedBox.shrink();
              }

              final hasCompletion = _completionDays.contains(day);
              final isToday = _isToday(day);
              final isSelected = _isSelected(day);
              final currentDayDate = DateTime(
                _focusedDate.year,
                _focusedDate.month,
                day,
              );

              return GestureDetector(
                onTap: () => widget.onDateSelected?.call(currentDayDate),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFFFF3278)
                              : (isToday
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.transparent),
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: const Color(0xFFFF3278),
                                  width: 1,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : (isToday
                                      ? const Color(0xFFFF3278)
                                      : Colors.white),
                            fontWeight: (isToday || isSelected)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasCompletion)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFFF3278),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 4),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isNextMonthFuture() {
    final now = DateTime.now();
    final nextMonth = DateTime(_focusedDate.year, _focusedDate.month + 1);
    return nextMonth.isAfter(DateTime(now.year, now.month + 1));
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == _focusedDate.year &&
        now.month == _focusedDate.month &&
        now.day == day;
  }

  bool _isSelected(int day) {
    if (widget.selectedDate == null) return false;
    return widget.selectedDate!.year == _focusedDate.year &&
        widget.selectedDate!.month == _focusedDate.month &&
        widget.selectedDate!.day == day;
  }
}

class _DifficultyChartBars extends StatefulWidget {
  const _DifficultyChartBars({
    required this.entries,
    required this.onLevelSelected,
  });

  final List<_DifficultyChartEntry> entries;
  final ValueChanged<String> onLevelSelected;

  @override
  State<_DifficultyChartBars> createState() => _DifficultyChartBarsState();
}

class _DifficultyChartBarsState extends State<_DifficultyChartBars> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final maxCount = widget.entries.fold<int>(1, (prev, entry) {
      return entry.count > prev ? entry.count : prev;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = widget.entries.length * 48.0;
        final minWidth = constraints.maxWidth.isFinite
            ? math.max(constraints.maxWidth, baseWidth)
            : baseWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(widget.entries.length, (index) {
                final entry = widget.entries[index];
                final normalized = maxCount <= 0
                    ? 0.0
                    : entry.count / maxCount.toDouble();
                final heightFactor = normalized.clamp(0.04, 1.0);
                final isSelected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: _BouncingButton(
                    onTap: () {
                      setState(() {
                        _selectedIndex = isSelected ? null : index;
                      });
                      widget.onLevelSelected(entry.levelLabel);
                    },
                    child: SizedBox(
                      width: 36,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.count}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFactor,
                                widthFactor: 0.26,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFF3278)
                                        : const Color(0xFF9498A1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.levelLabel,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _ChartLoadingState extends StatelessWidget {
  const _ChartLoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: const Center(
        child: Text(
          '완등 기록이 아직 없어요.',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
        ),
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

class _BouncingButton extends StatefulWidget {
  const _BouncingButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class _DateCompletionList extends ConsumerWidget {
  const _DateCompletionList({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionsAsync = ref.watch(completionsByDateProvider(date));

    return completionsAsync.when(
      data: (completions) {
        if (completions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '해당 날짜는 완등 기록이 없습니다.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }
        return Column(
          children: completions
              .map((c) => _ProfileCompletionCard(completion: c))
              .toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Color(0xFFFF3278)),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('오류 발생: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _CompletionList extends ConsumerWidget {
  const _CompletionList({required this.level});
  final String level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionsAsync = ref.watch(completionsByLevelProvider(level));

    return completionsAsync.when(
      data: (completions) {
        if (completions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                '막대를 눌러 난이도별 완등 기록을 확인하세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white38,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return Column(
          children: completions
              .map((c) => _ProfileCompletionCard(completion: c))
              .toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: Color(0xFFFF3278)),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('오류 발생: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends ConsumerWidget {
  const _ProfileCompletionCard({required this.completion});

  final CompletionResponse completion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStoreProvider);
    final existingRoute = projectState.routeIndexMap[completion.routeId];

    final route =
        existingRoute ??
        RouteModel(
          id: completion.routeId,
          boulderId: 0,
          province: '',
          city: '',
          name: completion.routeName,
          pioneerName: '',
          latitude: 0,
          longitude: 0,
          sectorName: '',
          areaCode: '',
          routeLevel: completion.routeLevel,
          boulderName: completion.boulderName,
          likeCount: 0,
          liked: false,
          viewCount: 0,
          climberCount: 0,
          commentCount: 0,
          imageInfoList: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completed: true,
        );

    final formattedDate = _formatDate(completion.completedDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RouteCard(
        route: route,
        showEngagement:
            existingRoute != null, // Only show engagement if we have real data
        outerPadding: EdgeInsets.zero,
        onTap: () {
          context.push(AppRoutes.completionDetail, extra: completion);
        },
        footer: _CompletionFooter(
          dateLabel: formattedDate,
          completionRank: existingRoute?.climberCount,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }
}

class _CompletionFooter extends StatelessWidget {
  const _CompletionFooter({required this.dateLabel, this.completionRank});

  final String dateLabel;
  final int? completionRank;

  @override
  Widget build(BuildContext context) {
    final details = <String>[dateLabel];
    if (completionRank != null && completionRank! > 0) {
      details.add('$completionRank번째 완등');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.join(' · '),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
