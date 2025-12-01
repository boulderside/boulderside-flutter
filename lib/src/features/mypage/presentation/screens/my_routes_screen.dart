import 'package:boulderside_flutter/src/features/home/data/models/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/route_completion_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/route_completion_service.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/viewmodels/route_completion_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyRoutesScreen extends StatelessWidget {
  const MyRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RouteCompletionViewModel>(
      create: (context) => RouteCompletionViewModel(
        context.read<RouteCompletionService>(),
        context.read<RouteService>(),
      )..loadCompletions(),
      child: const _MyRoutesBody(),
    );
  }
}

class _MyRoutesBody extends StatefulWidget {
  const _MyRoutesBody();

  @override
  State<_MyRoutesBody> createState() => _MyRoutesBodyState();
}

class _MyRoutesBodyState extends State<_MyRoutesBody> {
  static const Color _backgroundColor = Color(0xFF181A20);
  static const Color _cardColor = Color(0xFF262A34);
  static const Color _accentColor = Color(0xFFFF3278);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RouteCompletionViewModel>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          '나의 루트',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        onPressed: () => _openCompletionFormSheet(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        backgroundColor: _cardColor,
        color: _accentColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const _CompletedRoutesSection(),
            if (viewModel.isMutating)
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

class _CompletedRoutesSection extends StatelessWidget {
  const _CompletedRoutesSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteCompletionViewModel>(
      builder: (context, viewModel, _) {
        final completions = viewModel.completions;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '나의 루트',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (viewModel.isLoading)
              const _SectionCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF3278),
                    ),
                  ),
                ),
              )
            else if (viewModel.errorMessage != null)
              _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: viewModel.loadCompletions,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (completions.isEmpty)
              _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                children: completions
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RouteCompletionCard(completion: item),
                        ))
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

class _RouteCompletionCard extends StatelessWidget {
  const _RouteCompletionCard({required this.completion});

  final RouteCompletionModel completion;

  @override
  Widget build(BuildContext context) {
    final route = completion.route;
    final statusColor =
        completion.completed ? const Color(0xFF41E69B) : Colors.amberAccent;

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
                  completion.displayTitle,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  completion.completed ? '완등' : '도전 중',
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
            completion.displaySubtitle,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          if ((completion.memo ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              completion.memo!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatDate(completion.updatedAt),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: '수정',
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () => _openCompletionFormSheet(
                  context,
                  completion: completion,
                ),
              ),
              IconButton(
                tooltip: '삭제',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          if (route == null &&
              context.read<RouteCompletionViewModel>().isRouteIndexLoading)
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

  Future<void> _confirmDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<RouteCompletionViewModel>();
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
            '“${completion.displayTitle}” 기록을 삭제하시겠습니까?',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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
        await viewModel.deleteCompletion(completion.routeId);
        messenger.showSnackBar(
          const SnackBar(content: Text('기록을 삭제했어요.')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('삭제하지 못했습니다: $e')),
        );
      }
    }
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
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$year.$month.$day 업데이트';
}

Future<void> _openCompletionFormSheet(
  BuildContext context, {
  RouteCompletionModel? completion,
}) async {
  final viewModel = context.read<RouteCompletionViewModel>();
  await viewModel.ensureRouteIndexLoaded();
  if (!context.mounted) return;
  final bool? saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider<RouteCompletionViewModel>.value(
      value: viewModel,
      child: RouteCompletionFormSheet(
        completion: completion,
      ),
    ),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completion == null ? '등반 기록을 추가했어요.' : '등반 기록을 수정했어요.',
        ),
      ),
    );
  }
}

class RouteCompletionFormSheet extends StatefulWidget {
  const RouteCompletionFormSheet({super.key, this.completion});

  final RouteCompletionModel? completion;

  @override
  State<RouteCompletionFormSheet> createState() =>
      _RouteCompletionFormSheetState();
}

class _RouteCompletionFormSheetState extends State<RouteCompletionFormSheet> {
  RouteModel? _selectedRoute;
  bool _completed = true;
  bool _isSubmitting = false;
  String _searchQuery = '';
  String? _formError;
  late final TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    final completion = widget.completion;
    _memoController = TextEditingController(text: completion?.memo ?? '');
    if (completion != null) {
      _completed = completion.completed;
      _selectedRoute = completion.route ??
          context.read<RouteCompletionViewModel>().routeById(
                completion.routeId,
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
    final viewModel = context.watch<RouteCompletionViewModel>();
    final routes = viewModel.availableRoutes;
    final filteredRoutes = widget.completion != null
        ? const <RouteModel>[]
        : routes
            .where(
              (route) => _matchesQuery(route, _searchQuery),
            )
            .take(15)
            .toList();

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
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      Expanded(
                        child: Text(
                          widget.completion == null ? '루트 등록' : '기록 수정',
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
                  if (widget.completion == null) ...[
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
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
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
                    if (viewModel.isRouteIndexLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF3278),
                          ),
                        ),
                      )
                    else if (viewModel.routeIndexError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.routeIndexError!,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: viewModel.ensureRouteIndexLoaded,
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
                                  final alreadyRegistered = viewModel
                                      .completions
                                      .any((c) => c.routeId == route.id);
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
                    if (_selectedRoute != null)
                      Text(
                        '선택한 루트: ${_selectedRoute!.name}',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                        ),
                      ),
                  ] else
                    _SelectedRouteSummary(
                      title: widget.completion!.displayTitle,
                      subtitle: widget.completion!.displaySubtitle,
                    ),
                  const SizedBox(height: 20),
                  _CompletedToggle(
                    value: _completed,
                    onChanged: (value) => setState(() => _completed = value),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _memoController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: '메모 (선택)',
                      alignLabelWithHint: true,
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
                      onPressed:
                          _isSubmitting ? null : () => _handleSubmit(context),
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

  bool _matchesQuery(RouteModel route, String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    return route.name.toLowerCase().contains(lower) ||
        route.routeLevel.toLowerCase().contains(lower) ||
        route.city.toLowerCase().contains(lower) ||
        route.province.toLowerCase().contains(lower);
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

    final viewModel = context.read<RouteCompletionViewModel>();
    final navigator = Navigator.of(context);
    final memo =
        _memoController.text.trim().isEmpty ? null : _memoController.text.trim();

    try {
      if (widget.completion == null) {
        await viewModel.addCompletion(
          routeId: _selectedRoute!.id,
          completed: _completed,
          memo: memo,
        );
      } else {
        await viewModel.updateCompletion(
          routeId: widget.completion!.routeId,
          completed: _completed,
          memo: memo,
        );
      }
      if (!mounted) return;
      navigator.pop(true);
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
}

class _CompletedToggle extends StatelessWidget {
  const _CompletedToggle({
    required this.value,
    required this.onChanged,
  });

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
  const _SelectedRouteSummary({
    required this.title,
    required this.subtitle,
  });

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
