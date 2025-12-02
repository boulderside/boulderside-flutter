import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/route_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/intro_text.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_sort_option.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/widgets/sort_option_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RouteList extends StatelessWidget {
  const RouteList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di<RouteListViewModel>(),
      child: const _RouteListContent(),
    );
  }
}

class _RouteListContent extends StatefulWidget {
  const _RouteListContent();

  @override
  State<_RouteListContent> createState() => _RouteListContentState();
}

class _RouteListContentState extends State<_RouteListContent>
    with InfiniteScrollMixin<_RouteListContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<RouteListViewModel>(context, listen: false).loadInitial();
    });
  }

  @override
  bool get canLoadMore {
    final viewModel = context.read<RouteListViewModel>();
    return !viewModel.isLoading && viewModel.hasNext;
  }

  @override
  Future<void> onNearBottom() async {
    await context.read<RouteListViewModel>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.routes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF3278)),
          );
        }

        if (viewModel.errorMessage != null && viewModel.routes.isEmpty) {
          return _ListErrorView(
            message: viewModel.errorMessage!,
            onRetry: viewModel.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          backgroundColor: const Color(0xFF262A34),
          color: const Color(0xFFFF3278),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // 추천 바위 리스트
              const SizedBox(height: 10),
              const RecBoulderList(),

              // 텍스트
              const IntroText(),

              SortOptionBar<RouteSortOption>(
                options: const [
                  SortOption(label: '난이도순', value: RouteSortOption.difficulty),
                  SortOption(label: '좋아요순', value: RouteSortOption.liked),
                  SortOption(label: '동반자순', value: RouteSortOption.climbers),
                ],
                selectedValue: viewModel.currentSort,
                onSelected: viewModel.changeSort,
              ),

              if (viewModel.errorMessage != null && viewModel.routes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _InlineError(message: viewModel.errorMessage!),
                ),

              // 루트 카드 리스트
              ...viewModel.routes.map(
                (route) => RouteCard(
                  route: route,
                  onTap: () =>
                      context.push(AppRoutes.routeDetail, extra: route),
                ),
              ),

              // 로딩 인디케이터
              if (viewModel.isLoading)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3278)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ListErrorView extends StatelessWidget {
  const _ListErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x332F3440),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
      ),
    );
  }
}
