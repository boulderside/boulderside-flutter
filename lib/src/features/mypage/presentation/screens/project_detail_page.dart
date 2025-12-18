import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completion_providers.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completed_projects_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_summary_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_info.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/route_completion_page.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({super.key, required this.project});

  final ProjectModel project;

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {
  bool _isDeleting = false;
  bool _isOpeningCompletion = false;
  bool _isCancellingCompletion = false;
  ProjectModel? _projectOverride;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectStoreProvider.notifier).ensureRouteIndexLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectStoreProvider);
    ProjectModel? projectFromStore;
    for (final item in state.projects) {
      if (item.projectId == widget.project.projectId) {
        projectFromStore = item;
        break;
      }
    }
    final project = projectFromStore ?? _projectOverride ?? widget.project;
    return Scaffold(
      backgroundColor: const Color(0xFF1F2229),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2229),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '프로젝트 상세',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: _ProjectDetailBody(
          project: project,
          route: state.routeIndexMap[project.routeId],
          fallbackRouteInfo: project.routeInfo,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (project.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCancellingCompletion
                      ? null
                      : () => _confirmCancelCompletion(project),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: _isCancellingCompletion
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('완등 취소'),
                ),
              ),
            if (project.completed) const SizedBox(height: 12),
            if (!project.completed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOpeningCompletion
                      ? null
                      : () => _openCompletionFlow(project),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3278),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  child: _isOpeningCompletion
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '완등 기록하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            if (!project.completed) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isDeleting
                    ? null
                    : project.completed
                        ? _showNeedCancelDialog
                        : () => _handleDelete(project),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70,
                        ),
                      )
                    : const Text('프로젝트 삭제'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '프로젝트 삭제',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: Text(
          '“${project.displayTitle}” 프로젝트를 삭제할까요?',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard')),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref
          .read(projectStoreProvider.notifier)
          .deleteProject(project.projectId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로젝트를 삭제했어요.')));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _openCompletionFlow(ProjectModel project) async {
    final store = ref.read(projectStoreProvider.notifier);
    RouteModel? route = store.routeById(project.routeId);
    if (route == null) {
      await store.ensureRouteIndexLoaded();
      route = store.routeById(project.routeId);
    }
    if (route == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('루트 정보를 불러오지 못했어요. 잠시 후 다시 시도해주세요.')),
      );
      return;
    }

    setState(() {
      _isOpeningCompletion = true;
    });

    try {
      CompletionResponse? completion;
      try {
        completion = await ref.read(completionByRouteProvider(route.id).future);
      } catch (_) {
        completion = null;
      }
      if (!mounted) return;
      final bool? recorded = await context.push<bool>(
        AppRoutes.routeCompletion,
        extra: RouteCompletionPageArgs(route: route, completion: completion),
      );
      if (recorded == true && mounted) {
        await _refreshProjectDetail(route.id);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningCompletion = false;
        });
      }
    }
  }

  Future<void> _confirmCancelCompletion(ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '완등 취소',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: const Text(
          '이 프로젝트의 완등 기록을 취소할까요?',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('닫기', style: TextStyle(fontFamily: 'Pretendard')),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text(
              '완등 취소',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFFF6B81),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _cancelCompletion(project);
    }
  }

  Future<void> _cancelCompletion(ProjectModel project) async {
    setState(() => _isCancellingCompletion = true);
    final service = di<CompletionService>();
    try {
      final completion = await service.fetchCompletionByRoute(project.routeId);
      if (completion == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('완등 기록을 찾지 못했어요.')),
          );
        }
        return;
      }
      await service.deleteCompletion(completion.completionId);
      await _refreshProjectDetail(project.routeId);
      ref.invalidate(projectSummaryProvider);
      ref.invalidate(completedCompletionsProvider);
      ref.invalidate(completionByRouteProvider(project.routeId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('완등을 취소했어요.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('완등을 취소하지 못했습니다: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancellingCompletion = false);
      }
    }
  }

  Future<void> _showNeedCancelDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '완등 취소가 필요해요',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        content: const Text(
          '완등을 취소한 뒤에 프로젝트를 삭제할 수 있어요.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('확인', style: TextStyle(fontFamily: 'Pretendard')),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProjectDetail(int routeId) async {
    final fetched =
        await ref.read(projectStoreProvider.notifier).fetchProjectByRoute(routeId);
    if (mounted && fetched != null) {
      setState(() {
        _projectOverride = fetched;
      });
    }
  }
}

class _ProjectDetailBody extends ConsumerStatefulWidget {
  const _ProjectDetailBody({
    required this.project,
    required this.route,
    required this.fallbackRouteInfo,
  });

  final ProjectModel project;
  final RouteModel? route;
  final RouteInfo? fallbackRouteInfo;

  @override
  ConsumerState<_ProjectDetailBody> createState() => _ProjectDetailBodyState();
}

class _ProjectDetailBodyState extends ConsumerState<_ProjectDetailBody> {
  late TextEditingController _memoController;
  bool _isEditingMemo = false;
  bool _memoSubmitting = false;
  bool _isEditingSessions = false;
  bool _sessionsSubmitting = false;
  List<_SessionEditEntry> _sessionEdits = <_SessionEditEntry>[];

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.project.memo ?? '');
    _resetSessionEdits();
  }

  @override
  void didUpdateWidget(covariant _ProjectDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditingMemo && oldWidget.project.memo != widget.project.memo) {
      _memoController.text = widget.project.memo ?? '';
    }
    if (!_isEditingSessions &&
        oldWidget.project.sessions != widget.project.sessions) {
      _resetSessionEdits();
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _resetSessionEdits() {
    _sessionEdits =
        widget.project.sessions
            .map(
              (history) => _SessionEditEntry(
                sessionDate: history.sessionDate,
                sessionCount: history.sessionCount,
              ),
            )
            .toList()
          ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
  }

  @override
  Widget build(BuildContext context) {
    final attempts = List<ProjectSessionModel>.from(widget.project.sessions)
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(label: '루트 정보'),
        const SizedBox(height: 8),
        _RouteInformationCard(
          routeId: widget.project.routeId,
          route: widget.route,
          fallbackInfo: widget.fallbackRouteInfo,
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          label: '메모',
          isEditing: _isEditingMemo,
          onEdit: _toggleMemoEditing,
          onCancel: _memoSubmitting ? null : _toggleMemoEditing,
          onSave: _memoSubmitting ? null : _saveMemo,
          isSaving: _memoSubmitting,
        ),
        const SizedBox(height: 8),
        _isEditingMemo
            ? _buildMemoEditor()
            : _MemoCard(memo: widget.project.memo),
        const SizedBox(height: 24),
        _SectionHeader(
          label: '세션',
          isEditing: _isEditingSessions,
          onEdit: _toggleSessionEditing,
          onCancel: _sessionsSubmitting ? null : _toggleSessionEditing,
          onSave: _sessionsSubmitting ? null : _saveSessions,
          isSaving: _sessionsSubmitting,
        ),
        const SizedBox(height: 8),
        _isEditingSessions
            ? _buildSessionEditor()
            : _SessionList(attempts: attempts),
      ],
    );
  }

  void _toggleMemoEditing() {
    setState(() {
      if (_isEditingMemo) {
        _memoController.text = widget.project.memo ?? '';
      }
      _isEditingMemo = !_isEditingMemo;
    });
  }

  void _toggleSessionEditing() {
    setState(() {
      if (_isEditingSessions) {
        _resetSessionEdits();
      }
      _isEditingSessions = !_isEditingSessions;
    });
  }

  Widget _buildMemoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _memoController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '메모를 입력하세요.',
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white54,
              ),
              counterText: '',
            ),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (_sessionEdits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    '세션을 추가해 보세요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white54,
                    ),
                  ),
                )
              else
                Column(
                  children: _sessionEdits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickSessionDate(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF303543),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _formatDate(data.sessionDate),
                                      style: const TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _SessionStepper(
                                value: data.sessionCount,
                                onIncrement: () =>
                                    _changeAttemptCount(index, 1),
                                onDecrement: () =>
                                    _changeAttemptCount(index, -1),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white54,
                                ),
                                onPressed: () => _removeSession(index),
                              ),
                            ],
                          ),
                        ),
                        if (index != _sessionEdits.length - 1)
                          Divider(
                            color: Colors.white.withValues(alpha: 0.06),
                            height: 1,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              TextButton.icon(
                onPressed: _addSession,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '세션 추가',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveMemo() async {
    if (_memoSubmitting) return;
    setState(() {
      _memoSubmitting = true;
    });
    try {
      await ref
          .read(projectStoreProvider.notifier)
          .updateProject(
            projectId: widget.project.projectId,
            completed: widget.project.completed,
            memo: _memoController.text.trim().isEmpty
                ? null
                : _memoController.text.trim(),
            sessions: widget.project.sessions,
          );
      if (!mounted) return;
      setState(() {
        _isEditingMemo = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('메모를 저장했어요.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _memoSubmitting = false;
        });
      }
    }
  }

  Future<void> _saveSessions() async {
    if (_sessionsSubmitting) return;
    setState(() {
      _sessionsSubmitting = true;
    });
    try {
      final histories = _sessionEdits
          .map(
            (entry) => ProjectSessionModel(
              sessionDate: entry.sessionDate,
              sessionCount: entry.sessionCount,
            ),
          )
          .toList();
      await ref
          .read(projectStoreProvider.notifier)
          .updateProject(
            projectId: widget.project.projectId,
            completed: widget.project.completed,
            memo: widget.project.memo,
            sessions: histories,
          );
      if (!mounted) return;
      setState(() {
        _isEditingSessions = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('세션을 저장했어요.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _sessionsSubmitting = false;
        });
      }
    }
  }

  void _addSession() {
    setState(() {
      _sessionEdits.add(
        _SessionEditEntry(sessionDate: DateTime.now(), sessionCount: 1),
      );
    });
  }

  void _removeSession(int index) {
    if (index < 0 || index >= _sessionEdits.length) return;
    setState(() {
      _sessionEdits.removeAt(index);
    });
  }

  void _changeAttemptCount(int index, int delta) {
    if (index < 0 || index >= _sessionEdits.length) return;
    setState(() {
      final entry = _sessionEdits[index];
      final next = (entry.sessionCount + delta).clamp(1, 999);
      _sessionEdits[index] = entry.copyWith(sessionCount: next);
    });
  }

  Future<void> _pickSessionDate(int index) async {
    if (index < 0 || index >= _sessionEdits.length) return;
    final entry = _sessionEdits[index];
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entry.sessionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '세션 날짜 선택',
    );
    if (picked != null) {
      setState(() {
        _sessionEdits[index] = entry.copyWith(sessionDate: picked);
        _sessionEdits.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
      });
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.isEditing = false,
    this.onEdit,
    this.onCancel,
    this.onSave,
    this.isSaving = false,
  });

  final String label;
  final bool isEditing;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        if (!isEditing && onEdit != null)
          TextButton(
            onPressed: onEdit,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              foregroundColor: Colors.white70,
              textStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
              ),
            ),
            child: const Text('편집'),
          )
        else if (isEditing)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white54,
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                  ),
                ),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: onSave,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF41E69B),
                  textStyle: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF41E69B),
                        ),
                      )
                    : const Text('저장'),
              ),
            ],
          ),
      ],
    );
  }
}

class _RouteInformationCard extends StatelessWidget {
  const _RouteInformationCard({
    required this.routeId,
    this.route,
    this.fallbackInfo,
  });

  final int routeId;
  final RouteModel? route;
  final RouteInfo? fallbackInfo;

  @override
  Widget build(BuildContext context) {
    if (route != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: RouteCard(
          route: route!,
          outerPadding: EdgeInsets.zero,
          showEngagement: false,
          onTap: () => context.push(AppRoutes.routeDetail, extra: route),
        ),
      );
    }

    final String title = (fallbackInfo?.name ?? '').trim();
    final String level = (fallbackInfo?.routeLevel ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.isNotEmpty ? title : '루트 #$routeId',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (level.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x22FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemoCard extends StatelessWidget {
  const _MemoCard({this.memo});

  final String? memo;

  @override
  Widget build(BuildContext context) {
    final hasMemo = memo != null && memo!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        hasMemo ? memo! : '메모가 없습니다.',
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: hasMemo ? Colors.white : Colors.white38,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.attempts});

  final List<ProjectSessionModel> attempts;

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF262A34),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '세션 기록이 아직 없어요.',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: attempts.map((attempt) {
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
                title: Text(
                  _formatDate(attempt.sessionDate),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                trailing: Text(
                  '${attempt.sessionCount}회',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (attempt != attempts.last)
                Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SessionStepper extends StatelessWidget {
  const _SessionStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(icon: Icons.remove, onPressed: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$value회',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _RoundIconButton(icon: Icons.add, onPressed: onIncrement),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF373C48),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _SessionEditEntry {
  const _SessionEditEntry({
    required this.sessionDate,
    required this.sessionCount,
  });

  final DateTime sessionDate;
  final int sessionCount;

  _SessionEditEntry copyWith({DateTime? sessionDate, int? sessionCount}) {
    return _SessionEditEntry(
      sessionDate: sessionDate ?? this.sessionDate,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }
}

String _formatDate(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}
