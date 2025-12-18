import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completed_projects_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_summary_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_request.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_info.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/completion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompletionDetailPage extends ConsumerStatefulWidget {
  const CompletionDetailPage({super.key, required this.completion});

  final CompletionResponse completion;

  @override
  ConsumerState<CompletionDetailPage> createState() =>
      _CompletionDetailPageState();
}

class _CompletionDetailPageState extends ConsumerState<CompletionDetailPage> {
  late CompletionResponse _completion;
  bool _isEditingDate = false;
  bool _isEditingMemo = false;
  bool _isSavingDate = false;
  bool _isSavingMemo = false;
  bool _isCancelling = false;
  late DateTime _editingDate;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _completion = widget.completion;
    _editingDate = _completion.completedDate;
    _memoController = TextEditingController(text: _completion.memo ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectStoreProvider.notifier).ensureRouteIndexLoaded();
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ref
        .watch(projectStoreProvider)
        .routeIndexMap[_completion.routeId];
    return Scaffold(
      backgroundColor: const Color(0xFF1F2229),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2229),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          '완등 상세',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionHeader(label: '루트 정보'),
            const SizedBox(height: 8),
            _RouteInformationCard(
              routeId: _completion.routeId,
              route: route,
              fallbackInfo: route?.toRouteInfo(),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              label: '완등일',
              isEditing: _isEditingDate,
              onEdit: _toggleDateEditing,
              onCancel: _isSavingDate ? null : _toggleDateEditing,
              onSave: _isSavingDate ? null : _saveDate,
              isSaving: _isSavingDate,
            ),
            const SizedBox(height: 8),
            _buildDateCard(),
            const SizedBox(height: 24),
            _SectionHeader(
              label: '메모',
              isEditing: _isEditingMemo,
              onEdit: _toggleMemoEditing,
              onCancel: _isSavingMemo ? null : _toggleMemoEditing,
              onSave: _isSavingMemo ? null : _saveMemo,
              isSaving: _isSavingMemo,
            ),
            const SizedBox(height: 8),
            _isEditingMemo
                ? _buildMemoEditor()
                : _MemoCard(memo: _completion.memo),
            const SizedBox(height: 32),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    final displayDate = _formatDate(
      _isEditingDate ? _editingDate : _completion.completedDate,
    );
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(
            displayDate,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (_isEditingDate)
            TextButton(onPressed: _pickDate, child: const Text('날짜 선택')),
        ],
      ),
    );
    if (!_isEditingDate) return child;
    return GestureDetector(onTap: _pickDate, child: child);
  }

  Widget _buildMemoEditor() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _memoController,
        maxLength: 500,
        maxLines: 5,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '메모를 입력하세요.',
          hintStyle: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
          counterText: '',
        ),
        style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _isCancelling ? null : _confirmCancelCompletion,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0x33FF4D67),
        foregroundColor: const Color(0xFFFF8AAE),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: _isCancelling
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF8AAE),
              ),
            )
          : const Text('완등 취소'),
    );
  }

  void _toggleDateEditing() {
    setState(() {
      if (_isEditingDate) {
        _editingDate = _completion.completedDate;
      }
      _isEditingDate = !_isEditingDate;
    });
  }

  void _toggleMemoEditing() {
    setState(() {
      if (_isEditingMemo) {
        _memoController.text = _completion.memo ?? '';
      }
      _isEditingMemo = !_isEditingMemo;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _editingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: '완등일 선택',
    );
    if (picked != null) {
      setState(() => _editingDate = picked);
    }
  }

  Future<void> _saveDate() async {
    await _updateCompletion(
      completedDate: _editingDate,
      memo: _completion.memo,
      onSubmitting: (value) => setState(() => _isSavingDate = value),
      onComplete: () {
        setState(() {
          _isEditingDate = false;
        });
      },
    );
  }

  Future<void> _saveMemo() async {
    final memoText = _memoController.text.trim();
    await _updateCompletion(
      completedDate: _completion.completedDate,
      memo: memoText.isEmpty ? null : memoText,
      onSubmitting: (value) => setState(() => _isSavingMemo = value),
      onComplete: () {
        setState(() {
          _isEditingMemo = false;
        });
      },
    );
  }

  Future<void> _updateCompletion({
    required DateTime completedDate,
    String? memo,
    required void Function(bool) onSubmitting,
    required VoidCallback onComplete,
  }) async {
    onSubmitting(true);
    final request = CompletionRequest(
      routeId: _completion.routeId,
      completedDate: completedDate,
      memo: memo,
      completed: true,
    );
    final service = di<CompletionService>();
    try {
      final updated = await service.updateCompletion(
        completionId: _completion.completionId,
        request: request,
      );
      setState(() {
        _completion = updated;
        _editingDate = updated.completedDate;
        _memoController.text = updated.memo ?? '';
      });
      await ref.read(completedCompletionsProvider.notifier).refresh();
      ref.invalidate(projectSummaryProvider);
      onComplete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('완등 기록을 저장했어요.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $error')));
    } finally {
      onSubmitting(false);
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
  }

  Future<void> _confirmCancelCompletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '완등 취소',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '이 완등 기록을 삭제할까요?',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFFF6B6B),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteCompletion();
    }
  }

  Future<void> _deleteCompletion() async {
    setState(() => _isCancelling = true);
    final service = di<CompletionService>();
    try {
      await service.deleteCompletion(_completion.completionId);
      await ref.read(completedCompletionsProvider.notifier).refresh();
      ref.invalidate(projectSummaryProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('완등 기록을 삭제했어요.')));
      context.pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $error')));
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
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
    final title = (fallbackInfo?.name ?? '').trim();
    final level = (fallbackInfo?.routeLevel ?? '').trim();

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

extension on RouteModel {
  RouteInfo toRouteInfo() {
    return RouteInfo(
      name: name,
      routeLevel: routeLevel,
      climberCount: climberCount,
      likeCount: likeCount,
      viewCount: viewCount,
      commentCount: commentCount,
    );
  }
}
