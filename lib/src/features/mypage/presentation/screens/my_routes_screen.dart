import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_attempt_history_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyRoutesScreen extends ConsumerStatefulWidget {
  const MyRoutesScreen({super.key});

  @override
  ConsumerState<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends ConsumerState<MyRoutesScreen> {
  static const Color _backgroundColor = Color(0xFF181A20);
  static const Color _cardColor = Color(0xFF262A34);
  static const Color _accentColor = Color(0xFFFF3278);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectStoreProvider.notifier).loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectStoreProvider);
    final store = ref.read(projectStoreProvider.notifier);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          '내 프로젝트',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _backgroundColor,
        centerTitle: false,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        backgroundColor: _cardColor,
        color: _accentColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const _CompletedRoutesSection(),
            if (state.isMutating)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: LinearProgressIndicator(
                  color: _accentColor,
                  backgroundColor: Color(0x33FFFFFF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompletedRoutesSection extends ConsumerWidget {
  const _CompletedRoutesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectStoreProvider);
    final projects = state.projects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isLoading)
          const _SectionCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
          )
        else if (state.errorMessage != null)
          _SectionCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: ref
                        .read(projectStoreProvider.notifier)
                        .loadProjects,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          )
        else if (projects.isEmpty)
          const _SectionCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '아직 등록된 등반 기록이 없어요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '지금까지 완등한 루트를 기록해보세요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: projects
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ProjectCard(project: item),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectStoreProvider);
    final route = project.route;
    final statusColor = project.completed
        ? const Color(0xFF41E69B)
        : Colors.amberAccent;
    final isRouteIndexLoading = state.isRouteIndexLoading;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.displayTitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  project.completed ? '완등' : '도전 중',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            project.displaySubtitle,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          if ((project.memo ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              project.memo!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
              ),
            ),
          ],
          if (project.attemptHistories.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AttemptHistorySummary(histories: project.attemptHistories),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatDate(project.updatedAt),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: '상세보기',
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white70,
                ),
                onPressed: () => _openRouteDetail(context, ref),
              ),
              IconButton(
                tooltip: '수정',
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () =>
                    _openProjectFormSheet(context, ref, completion: project),
              ),
              IconButton(
                tooltip: '삭제',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          if (route == null && isRouteIndexLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(
                color: Color(0xFFFF3278),
                backgroundColor: Color(0x33FFFFFF),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final store = ref.read(projectStoreProvider.notifier);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262A34),
          title: const Text(
            '기록 삭제',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
          content: Text(
            '“${project.displayTitle}” 기록을 삭제하시겠습니까?',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard'),
              ),
            ),
            TextButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (result == true) {
      try {
        await store.deleteProject(project.projectId);
        messenger.showSnackBar(const SnackBar(content: Text('기록을 삭제했어요.')));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $e')));
      }
    }
  }

  Future<void> _openRouteDetail(BuildContext context, WidgetRef ref) async {
    final store = ref.read(projectStoreProvider.notifier);
    RouteModel? route = project.route ?? store.routeById(project.routeId);
    if (route == null) {
      await store.ensureRouteIndexLoaded();
      route = store.routeById(project.routeId);
    }
    if (!context.mounted) return;
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('루트 정보를 불러오지 못했습니다. 다시 시도해주세요.')),
      );
      return;
    }
    context.push(AppRoutes.routeDetail, extra: route);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

String _formatDate(DateTime dateTime) {
  return '${_formatShortDate(dateTime)} 업데이트';
}

String _formatShortDate(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}

Future<void> _openProjectFormSheet(
  BuildContext context,
  WidgetRef ref, {
  ProjectModel? completion,
  RouteModel? initialRoute,
}) async {
  final store = ref.read(projectStoreProvider.notifier);
  await store.ensureRouteIndexLoaded();
  if (!context.mounted) return;
  final bool? saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        ProjectFormSheet(completion: completion, initialRoute: initialRoute),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(completion == null ? '등반 기록을 추가했어요.' : '등반 기록을 수정했어요.'),
      ),
    );
  }
}

class ProjectFormSheet extends ConsumerStatefulWidget {
  const ProjectFormSheet({super.key, this.completion, this.initialRoute})
    : assert(
        completion == null || initialRoute == null,
        'initialRoute is only for new projects',
      );

  final ProjectModel? completion;
  final RouteModel? initialRoute;

  @override
  ConsumerState<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends ConsumerState<ProjectFormSheet> {
  RouteModel? _selectedRoute;
  bool _completed = true;
  bool _isSubmitting = false;
  String _searchQuery = '';
  String? _formError;
  late final TextEditingController _memoController;
  final List<_AttemptEntryController> _attemptEntries = [];

  @override
  void initState() {
    super.initState();
    final completion = widget.completion;
    _memoController = TextEditingController(text: completion?.memo ?? '');
    if (completion != null) {
      _completed = completion.completed;
      _selectedRoute =
          completion.route ??
          ref.read(projectStoreProvider.notifier).routeById(completion.routeId);
      for (final attempt in completion.attemptHistories) {
        _attemptEntries.add(
          _AttemptEntryController(
            attemptedDate: attempt.attemptedDate,
            attemptCount: attempt.attemptCount,
          ),
        );
      }
    } else {
      if (widget.initialRoute != null) {
        _selectedRoute = widget.initialRoute;
      }
      _attemptEntries.add(
        _AttemptEntryController(attemptedDate: DateTime.now()),
      );
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectStoreProvider);
    final store = ref.read(projectStoreProvider.notifier);
    final routes = state.availableRoutes;
    final showRouteSelector =
        widget.completion == null && widget.initialRoute == null;
    final filteredRoutes = showRouteSelector
        ? routes
              .where((route) => _matchesQuery(route, _searchQuery))
              .take(15)
              .toList()
        : const <RouteModel>[];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        decoration: const BoxDecoration(
          color: Color(0xFF1F2229),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                        onPressed: () => context.pop(false),
                      ),
                      Expanded(
                        child: Text(
                          widget.completion == null ? '프로젝트 등록' : '기록 수정',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (showRouteSelector) ...[
                    TextField(
                      onChanged: (value) => setState(() {
                        _searchQuery = value.trim();
                      }),
                      decoration: InputDecoration(
                        labelText: '루트 검색',
                        labelStyle: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2E333D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.isRouteIndexLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF3278),
                          ),
                        ),
                      )
                    else if (state.routeIndexError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.routeIndexError!,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: store.ensureRouteIndexLoaded,
                              child: const Text('루트 목록 다시 불러오기'),
                            ),
                          ],
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: filteredRoutes.isEmpty
                            ? const Center(
                                child: Text(
                                  '원하는 루트를 검색해 보세요.',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white54,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredRoutes.length,
                                itemBuilder: (context, index) {
                                  final route = filteredRoutes[index];
                                  final isSelected =
                                      _selectedRoute?.id == route.id;
                                  final alreadyRegistered = state.projects.any(
                                    (c) => c.routeId == route.id,
                                  );
                                  return ListTile(
                                    enabled: !alreadyRegistered,
                                    onTap: alreadyRegistered
                                        ? null
                                        : () => setState(() {
                                            _selectedRoute = route;
                                          }),
                                    title: Text(
                                      route.name,
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: alreadyRegistered
                                            ? Colors.white38
                                            : isSelected
                                            ? const Color(0xFFFF3278)
                                            : Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${route.routeLevel} · ${route.province} ${route.city}',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: alreadyRegistered
                                            ? Colors.white30
                                            : Colors.white54,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (alreadyRegistered)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0x33FFFFFF),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Text(
                                              '이미 등록됨',
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        if (isSelected)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Color(0xFFFF3278),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _selectedRoute == null
                            ? const SizedBox.shrink()
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '선택한 루트: ${_selectedRoute!.name}',
                                  style: const TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ] else if (widget.completion != null)
                    _SelectedRouteSummary(
                      title: widget.completion!.displayTitle,
                      subtitle: widget.completion!.displaySubtitle,
                    )
                  else if (widget.initialRoute != null)
                    _SelectedRouteSummary(
                      title: widget.initialRoute!.name,
                      subtitle:
                          '${widget.initialRoute!.routeLevel} · ${widget.initialRoute!.province} ${widget.initialRoute!.city}',
                    ),
                  const SizedBox(height: 20),
                  _CompletedToggle(
                    value: _completed,
                    onChanged: (value) => setState(() => _completed = value),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _memoController,
                    builder: (context, value, child) {
                      final length = value.text.length;
                      return Stack(
                        children: [
                          TextField(
                            controller: _memoController,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: '메모 (선택)',
                              alignLabelWithHint: true,
                              counterText: '',
                              labelStyle: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white70,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2E333D),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 12,
                            child: Text(
                              '$length/500',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAttemptHistoryInputs(),
                  if (_formError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _formError!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => _handleSubmit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3278),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.completion == null ? '등록하기' : '수정하기',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (widget.completion == null && _selectedRoute == null) {
      setState(() => _formError = '루트를 선택해주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    final store = ref.read(projectStoreProvider.notifier);
    final memo = _memoController.text.trim().isEmpty
        ? null
        : _memoController.text.trim();
    late final List<ProjectAttemptHistoryModel> attemptHistories;
    try {
      attemptHistories = _buildAttemptHistoryModels();
    } on _AttemptValidationException catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _formError = error.message;
        });
      }
      return;
    }

    try {
      if (widget.completion == null) {
        await store.addProject(
          routeId: _selectedRoute!.id,
          completed: _completed,
          memo: memo,
          attemptHistories: attemptHistories,
        );
      } else {
        await store.updateProject(
          projectId: widget.completion!.projectId,
          completed: _completed,
          memo: memo,
          attemptHistories: attemptHistories,
        );
      }
      if (!mounted) return;
      if (context.mounted) {
        context.pop(true);
      }
    } catch (e) {
      setState(() {
        _formError = '저장하지 못했습니다. 다시 시도해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildAttemptHistoryInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세션',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_attemptEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '세션을 추가해 보세요.',
              style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
            ),
          )
        else
          Column(
            children: _attemptEntries.asMap().entries.expand((entry) {
              final index = entry.key;
              final data = entry.value;
              final row = _AttemptHistoryField(
                key: ValueKey('attempt-$index'),
                entry: data,
                dateLabel: _formatShortDate(data.attemptedDate),
                onTapDate: () => _pickAttemptDate(index),
                onRemove: () => _removeAttemptEntry(index),
                onIncrement: () => _changeAttemptCount(index, 1),
                onDecrement: () => _changeAttemptCount(index, -1),
              );
              return [
                row,
                const Divider(
                  color: Color(0x33FFFFFF),
                  height: 12,
                  thickness: 0.5,
                ),
              ];
            }).toList()..removeLast(),
          ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _handleAddAttemptEntry,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            '세션 추가',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _handleAddAttemptEntry() {
    setState(() {
      _attemptEntries.add(
        _AttemptEntryController(attemptedDate: DateTime.now()),
      );
    });
  }

  void _removeAttemptEntry(int index) {
    if (index < 0 || index >= _attemptEntries.length) return;
    _attemptEntries.removeAt(index);
    setState(() {});
  }

  void _changeAttemptCount(int index, int delta) {
    if (index < 0 || index >= _attemptEntries.length) return;
    setState(() {
      final entry = _attemptEntries[index];
      final next = (entry.attemptCount + delta).clamp(1, 999);
      entry.attemptCount = next;
    });
  }

  Future<void> _pickAttemptDate(int index) async {
    if (index < 0 || index >= _attemptEntries.length) return;
    final entry = _attemptEntries[index];
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entry.attemptedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      confirmText: '선택',
      cancelText: '취소',
    );
    if (picked != null && mounted) {
      setState(() {
        entry.attemptedDate = picked;
      });
    }
  }

  List<ProjectAttemptHistoryModel> _buildAttemptHistoryModels() {
    if (_attemptEntries.isEmpty) {
      return const <ProjectAttemptHistoryModel>[];
    }
    final histories = <ProjectAttemptHistoryModel>[];
    for (final entry in _attemptEntries) {
      if (entry.attemptCount <= 0) {
        throw const _AttemptValidationException('세션 횟수는 1 이상이어야 합니다.');
      }
      histories.add(
        ProjectAttemptHistoryModel(
          attemptedDate: entry.attemptedDate,
          attemptCount: entry.attemptCount,
        ),
      );
    }
    return histories;
  }

  bool _matchesQuery(RouteModel route, String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    return route.name.toLowerCase().contains(lower) ||
        route.routeLevel.toLowerCase().contains(lower) ||
        route.city.toLowerCase().contains(lower) ||
        route.province.toLowerCase().contains(lower);
  }
}

class _CompletedToggle extends StatelessWidget {
  const _CompletedToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E333D),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            '완등 여부',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: Text(
              value ? '완등' : '도전 중',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFFFF3278)
                  : Colors.white70,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0x33FF3278)
                  : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedRouteSummary extends StatelessWidget {
  const _SelectedRouteSummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E333D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptHistorySummary extends StatelessWidget {
  const _AttemptHistorySummary({required this.histories});

  final List<ProjectAttemptHistoryModel> histories;

  @override
  Widget build(BuildContext context) {
    final sorted = List<ProjectAttemptHistoryModel>.from(histories)
      ..sort((a, b) => b.attemptedDate.compareTo(a.attemptedDate));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세션',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        ...sorted.map(
          (history) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Text(
                  _formatShortDate(history.attemptedDate),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${history.attemptCount}회',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AttemptHistoryField extends StatelessWidget {
  const _AttemptHistoryField({
    super.key,
    required this.entry,
    required this.dateLabel,
    required this.onTapDate,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  final _AttemptEntryController entry;
  final String dateLabel;
  final VoidCallback onTapDate;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapDate,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _StepperButton(
            icon: Icons.remove,
            onPressed: onDecrement,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${entry.attemptCount}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onPressed: onIncrement,
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '삭제',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _AttemptEntryController {
  _AttemptEntryController({required this.attemptedDate, int? attemptCount})
    : attemptCount = (attemptCount ?? 1).clamp(1, 999);

  DateTime attemptedDate;
  int attemptCount;
}

class _AttemptValidationException implements Exception {
  const _AttemptValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.transparent,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
