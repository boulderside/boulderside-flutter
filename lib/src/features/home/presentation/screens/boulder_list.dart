import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/boulder_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/intro_text.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/sort_button.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_card.dart';

class BoulderList extends StatefulWidget {
  const BoulderList({super.key});

  @override
  State<BoulderList> createState() => _BoulderListState();
}

class _BoulderListState extends State<BoulderList> {
  final ScrollController _scrollController = ScrollController();
  BoulderListViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_viewModel == null) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        !_viewModel!.isLoading &&
        _viewModel!.hasNext) {
      _viewModel!.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          BoulderListViewModel(context.read<BoulderService>())..loadInitial(),
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
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                // 추천 바위 리스트
                SizedBox(height: 10),
                RecBoulderList(),

                // 텍스트
                const IntroText(),

                // 정렬 버튼
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
                  child: Row(
                    children: [
                      SortButton(
                        text: '최신순',
                        selected: vm.currentSort == BoulderSortOption.latest,
                        onTap: () => vm.changeSort(BoulderSortOption.latest),
                      ),
                      const SizedBox(width: 10),
                      SortButton(
                        text: '좋아요순',
                        selected: vm.currentSort == BoulderSortOption.popular,
                        onTap: () => vm.changeSort(BoulderSortOption.popular),
                      ),
                      // const SizedBox(width: 10),
                      // SortButton(
                      //   text: '인기순',
                      //   selected: _currentSort == BoulderSortOption.popular,
                      //   onTap: () => _changeSort(BoulderSortOption.popular),
                      // ),
                    ].divide(const SizedBox(width: 0)),
                  ),
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
