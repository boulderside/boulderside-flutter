import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/route_instagram_create_page.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_instagrams_store.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/instagram_edit_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MyInstagramsScreen extends ConsumerStatefulWidget {
  const MyInstagramsScreen({super.key});

  @override
  ConsumerState<MyInstagramsScreen> createState() => _MyInstagramsScreenState();
}

class _MyInstagramsScreenState extends ConsumerState<MyInstagramsScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<RouteModel>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _routesFuture = di<RouteIndexCache>().load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myInstagramsStoreProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final feed = ref.read(myInstagramsFeedProvider);
      if (feed.hasNext && !feed.isLoadingMore) {
        ref.read(myInstagramsStoreProvider.notifier).loadMore();
      }
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(myInstagramsStoreProvider.notifier).refresh();
    if (mounted) {
      setState(() {
        _routesFuture = di<RouteIndexCache>().refresh();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(myInstagramsFeedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '내 풀이',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: FutureBuilder<List<RouteModel>>(
        future: _routesFuture,
        builder: (context, snapshot) {
          final routes = snapshot.data ?? const <RouteModel>[];
          final routeMap = {for (final route in routes) route.id: route};
          final hasRouteError = snapshot.hasError;
          return _buildBody(feed, routeMap, hasRouteError: hasRouteError);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF3278),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _openCreateInstagram(context),
      ),
    );
  }

  Future<void> _openCreateInstagram(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const RouteInstagramCreatePage()),
    );
    if (created == true && mounted) {
      await _onRefresh();
    }
  }

  Widget _buildBody(
    MyInstagramsFeedViewData feed,
    Map<int, RouteModel> routeMap, {
    bool hasRouteError = false,
  }) {
    // Initial loading
    if (feed.isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    // Error with no items
    if (feed.errorMessage != null && feed.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              feed.errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(myInstagramsStoreProvider.notifier).loadInitial(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(color: Colors.white, fontFamily: 'Pretendard'),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (feed.items.isEmpty) {
      return const Center(
        child: Text(
          '등록된 인스타그램 게시글이 없습니다.',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Pretendard',
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFFFF3278),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount:
            feed.items.length +
            (hasRouteError ? 1 : 0) +
            (feed.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasRouteError && index == 0) {
            return _RouteLoadErrorCard(
              onRetry: () {
                setState(() {
                  _routesFuture = di<RouteIndexCache>().refresh();
                });
              },
            );
          }

          final itemIndex = index - (hasRouteError ? 1 : 0);
          if (itemIndex >= feed.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF3278)),
              ),
            );
          }

          final item = feed.items[itemIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InstagramPreviewCard(
              instagram: item,
              routeMap: routeMap,
              onEdit: () async {
                await context.push(
                  AppRoutes.myInstagramEdit,
                  extra: InstagramEditPageArgs(instagram: item),
                );
              },
              onDelete: () => _confirmDelete(context, item),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Instagram instagram) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '인스타그램 삭제',
          style: TextStyle(color: Colors.white, fontFamily: 'Pretendard'),
        ),
        content: const Text(
          '선택한 인스타그램 게시글을 삭제할까요?',
          style: TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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

    await ref
        .read(myInstagramsStoreProvider.notifier)
        .deleteInstagram(instagram.id);
  }
}

class _RouteLoadErrorCard extends StatelessWidget {
  const _RouteLoadErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '루트 정보를 불러오지 못했습니다.',
            style: TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _InstagramPreviewCard extends StatefulWidget {
  const _InstagramPreviewCard({
    required this.instagram,
    required this.routeMap,
    required this.onEdit,
    required this.onDelete,
  });

  final Instagram instagram;
  final Map<int, RouteModel> routeMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_InstagramPreviewCard> createState() => _InstagramPreviewCardState();
}

class _InstagramPreviewCardState extends State<_InstagramPreviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final routeLabels = widget.instagram.routeIds
        .map((id) => widget.routeMap[id]?.name ?? '루트 #$id')
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2129),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E333D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FaIcon(
                FontAwesomeIcons.instagram,
                color: Color(0xFFFF3278),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '연결된 인스타그램 게시글',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.instagram.url,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Pretendard',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() => _isExpanded = !_isExpanded);
                },
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                ),
                label: Text(
                  _isExpanded ? '접기' : '펼치기',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Pretendard',
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const Spacer(),
              Text(
                '루트 ${routeLabels.length}개',
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: routeLabels
                  .map(
                    (label) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2E333D)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onEdit,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF3278)),
                    foregroundColor: const Color(0xFFFF3278),
                  ),
                  child: const Text(
                    '수정',
                    style: TextStyle(fontFamily: 'Pretendard'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onDelete,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E333D)),
                    foregroundColor: Colors.white70,
                  ),
                  child: const Text(
                    '삭제',
                    style: TextStyle(fontFamily: 'Pretendard'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
