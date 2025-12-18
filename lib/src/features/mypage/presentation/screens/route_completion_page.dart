import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completed_projects_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_summary_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_request.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_session_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouteCompletionPageArgs {
  const RouteCompletionPageArgs({required this.route, this.completion});

  final RouteModel route;
  final CompletionResponse? completion;
}

class RouteCompletionPage extends ConsumerStatefulWidget {
  const RouteCompletionPage({super.key, required this.args});

  final RouteCompletionPageArgs args;

  @override
  ConsumerState<RouteCompletionPage> createState() =>
      _RouteCompletionPageState();
}

class _RouteCompletionPageState extends ConsumerState<RouteCompletionPage> {
  final TextEditingController _memoController = TextEditingController();
  late DateTime _selectedDate;
  bool _submitting = false;
  String? _errorMessage;

  CompletionResponse? get _editingCompletion => widget.args.completion;
  bool get _isEditing => _editingCompletion != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = _editingCompletion?.completedDate ?? DateTime.now();
    _memoController.text = _editingCompletion?.memo ?? '';
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '완등일 선택',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    final memoText = _memoController.text.trim();
    final request = CompletionRequest(
      routeId: widget.args.route.id,
      completedDate: _selectedDate,
      memo: memoText.isEmpty ? null : memoText,
      completed: true,
    );
    final CompletionService service = di<CompletionService>();
    try {
      if (_isEditing) {
        await service.updateCompletion(
          completionId: _editingCompletion!.completionId,
          request: request,
        );
      } else {
        await service.createCompletion(request);
      }
      await _syncProjectAfterCompletion(
        completedDate: _selectedDate,
        memo: memoText.isEmpty ? null : memoText,
      );
      if (!mounted) return;
      ref.invalidate(projectSummaryProvider);
      ref.invalidate(completedCompletionsProvider);
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = '완등 기록을 저장하지 못했습니다. 다시 시도해주세요.';
      });
    }
  }

  Future<void> _syncProjectAfterCompletion({
    required DateTime completedDate,
    String? memo,
  }) async {
    final store = ref.read(projectStoreProvider.notifier);
    final project = await store.fetchProjectByRoute(widget.args.route.id);
    if (project == null) return;
    final sessions = List<ProjectSessionModel>.from(project.sessions);
    final index = sessions.indexWhere(
      (entry) => _isSameDay(entry.sessionDate, completedDate),
    );
    if (index >= 0) {
      sessions[index] = ProjectSessionModel(
        sessionDate: completedDate,
        sessionCount: sessions[index].sessionCount,
      );
    } else {
      sessions.add(
        ProjectSessionModel(sessionDate: completedDate, sessionCount: 1),
      );
    }
    await store.updateProject(
      projectId: project.projectId,
      completed: true,
      memo: project.memo?.isNotEmpty == true ? project.memo : memo,
      sessions: sessions,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.args.route;
    final titleStyle = const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '완등 기록하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: Text(
              '완료',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: _submitting ? Colors.white38 : const Color(0xFFFF3278),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '루트 정보',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(route.name, style: titleStyle),
                  const SizedBox(height: 8),
                  Text(
                    '${route.routeLevel} · ${route.province} ${route.city}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '완등일',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: '날짜 선택',
                    onPressed: _pickDate,
                    icon: const Icon(
                      CupertinoIcons.calendar,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '메모 (선택)',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _memoController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: '완등 소감을 기록해보세요.',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.redAccent,
                ),
              ),
            ],
          ],
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
