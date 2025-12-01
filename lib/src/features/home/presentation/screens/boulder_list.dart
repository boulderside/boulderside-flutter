import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/intro_text.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/widgets/sort_option_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_card.dart';

class BoulderList extends StatefulWidget {
  const BoulderList({super.key});

  @override
  State<BoulderList> createState() => _BoulderListState();
}

class _BoulderListState extends State<BoulderList>
    with InfiniteScrollMixin<BoulderList> {
  BoulderListViewModel? _viewModel;
  @override
  bool get canLoadMore =>
      _viewModel != null && !_viewModel!.isLoading && _viewModel!.hasNext;

  @override
  Future<void> onNearBottom() async {
    await _viewModel?.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BoulderListViewModel(
        context.read<FetchBouldersUseCase>(),
      )..loadInitial(),
      child: Consumer<BoulderListViewModel>(
        builder: (context, vm, _) {
          // Store the viewModel reference for scroll listener
          _viewModel = vm;

          // 최초 데이터 로드 (목록 비어있고 로딩 중)
          if (vm.isLoading && vm.boulders.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF3278)),
            );
          }

          if (vm.errorMessage != null && vm.boulders.isEmpty) {
            return _ListErrorView(
              message: vm.errorMessage!,
              onRetry: vm.refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 추천 바위 리스트
                SizedBox(height: 10),
                RecBoulderList(),

                // 텍스트
                const IntroText(),

                SortOptionBar<BoulderSortOption>(
                  options: const [
                    SortOption(
                      label: '최신순',
                      value: BoulderSortOption.latest,
                    ),
                    SortOption(
                      label: '좋아요순',
                      value: BoulderSortOption.popular,
                    ),
                  ],
                  selectedValue: vm.currentSort,
                  onSelected: vm.changeSort,
                ),

                if (vm.errorMessage != null && vm.boulders.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _InlineError(message: vm.errorMessage!),
                  ),

                // 바위 카드 리스트
                ...vm.boulders.map(
                  (boulder) => GestureDetector(
                    onTap: () =>
                        context.push(AppRoutes.boulderDetail, extra: boulder),
                    child: BoulderCard(boulder: boulder),
                  ),
                ),

                // 로딩 인디케이터
                if (vm.isLoading)
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3278),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
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
        style: const TextStyle(
          color: Colors.white70,
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }
}
