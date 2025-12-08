import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/boulder/application/boulder_store.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/intro_text.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/src/shared/mixins/infinite_scroll_mixin.dart';
import 'package:boulderside_flutter/src/shared/widgets/sort_option_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_card.dart';

class BoulderList extends ConsumerStatefulWidget {
  const BoulderList({super.key});

  @override
  ConsumerState<BoulderList> createState() => _BoulderListState();
}

class _BoulderListState extends ConsumerState<BoulderList>
    with InfiniteScrollMixin<BoulderList> {
  BoulderSortOption _currentSort = BoulderSortOption.latest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(boulderStoreProvider.notifier).loadInitialStandard(_currentSort);
    });
  }

  @override
  bool get canLoadMore {
    final feed = ref.read(boulderFeedProvider(_currentSort));
    return !feed.isLoadingMore && feed.hasNext;
  }

  @override
  Future<void> onNearBottom() async {
    await ref
        .read(boulderStoreProvider.notifier)
        .loadMoreStandard(_currentSort);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(boulderFeedProvider(_currentSort));

    if (feed.isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (feed.errorMessage != null && feed.items.isEmpty) {
      return _ListErrorView(
        message: feed.errorMessage!,
        onRetry: () => ref
            .read(boulderStoreProvider.notifier)
            .loadInitialStandard(_currentSort),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(boulderStoreProvider.notifier)
          .loadInitialStandard(_currentSort),
      backgroundColor: const Color(0xFF262A34),
      color: const Color(0xFFFF3278),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          const SizedBox(height: 10),
          const RecBoulderList(),
          const IntroText(),
          SortOptionBar<BoulderSortOption>(
            options: const [
              SortOption(label: '최신순', value: BoulderSortOption.latest),
              SortOption(label: '좋아요순', value: BoulderSortOption.popular),
            ],
            selectedValue: _currentSort,
            onSelected: (sort) {
              if (_currentSort == sort) return;
              setState(() {
                _currentSort = sort;
              });
              ref.read(boulderStoreProvider.notifier).loadInitialStandard(sort);
            },
          ),
          if (feed.errorMessage != null && feed.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InlineError(message: feed.errorMessage!),
            ),
          ...feed.items.map(
            (boulder) => GestureDetector(
              onTap: () =>
                  context.push(AppRoutes.boulderDetail, extra: boulder),
              child: BoulderCard(boulder: boulder),
            ),
          ),
          if (feed.isLoadingMore)
            Container(
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            ),
        ],
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
