import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/mypage/application/completed_projects_provider.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompletedRoutesScreen extends ConsumerStatefulWidget {
  const CompletedRoutesScreen({super.key});

  @override
  ConsumerState<CompletedRoutesScreen> createState() =>
      _CompletedRoutesScreenState();
}

class _CompletedRoutesScreenState extends ConsumerState<CompletedRoutesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(completedCompletionsProvider.notifier).loadInitial();
      ref.read(projectStoreProvider.notifier).ensureRouteIndexLoaded();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(completedCompletionsProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() {
    return ref.read(completedCompletionsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completedCompletionsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '완등한 루트',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFFFF3278),
        backgroundColor: const Color(0xFF262A34),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.completions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              );
            }
            if (state.errorMessage != null && state.completions.isEmpty) {
              return _CompletedErrorView(message: state.errorMessage!);
            }
            if (state.completions.isEmpty) {
              return const _CompletedEmptyView();
            }
            final itemCount =
                state.completions.length + (state.isLoadingMore ? 1 : 0);
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (index >= state.completions.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  );
                }
                final completion = state.completions[index];
                return _CompletedCompletionCard(completion: completion);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CompletedCompletionCard extends ConsumerWidget {
  const _CompletedCompletionCard({required this.completion});

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
          completed: false,
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

class _CompletedEmptyView extends StatelessWidget {
  const _CompletedEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flag_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              '아직 완등한 루트가 없어요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedErrorView extends ConsumerWidget {
  const _CompletedErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(completedCompletionsProvider.notifier).loadInitial();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
