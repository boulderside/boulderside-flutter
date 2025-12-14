import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_likes_store.dart';
import 'package:boulderside_flutter/src/shared/widgets/segmented_toggle_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyLikesScreen extends ConsumerStatefulWidget {
  const MyLikesScreen({super.key});

  @override
  ConsumerState<MyLikesScreen> createState() => _MyLikesScreenState();
}

class _MyLikesScreenState extends ConsumerState<MyLikesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = ref.read(myLikesStoreProvider.notifier);
      store.loadInitialBoulders();
      store.loadInitialRoutes();
    });
  }

  @override
  Widget build(BuildContext context) => const _MyLikesBody();
}

class _MyLikesBody extends StatefulWidget {
  const _MyLikesBody();

  @override
  State<_MyLikesBody> createState() => _MyLikesBodyState();
}

enum _LikesSegment { boulders, routes }

class _MyLikesBodyState extends State<_MyLikesBody> {
  static const Color _backgroundColor = Color(0xFF181A20);
  _LikesSegment _segment = _LikesSegment.boulders;

  @override
  Widget build(BuildContext context) {
    final Widget currentTab = _segment == _LikesSegment.boulders
        ? const _LikedBouldersTab()
        : const _LikedRoutesTab();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '좋아요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedToggleBar<_LikesSegment>(
                options: const [
                  SegmentOption(label: '바위', value: _LikesSegment.boulders),
                  SegmentOption(label: '루트', value: _LikesSegment.routes),
                ],
                selectedValue: _segment,
                onChanged: (segment) {
                  setState(() => _segment = segment);
                },
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(key: ValueKey(_segment), child: currentTab),
            ),
          ),
        ],
      ),
    );
  }
}

class _LikedRoutesTab extends StatelessWidget {
  const _LikedRoutesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final feed = ref.watch(likedRouteFeedProvider);
        final routes = feed.items;
        final store = ref.read(myLikesStoreProvider.notifier);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                feed.hasNext &&
                !feed.isLoadingMore) {
              store.loadMoreRoutes();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: store.refreshRoutes,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: feed.isInitialLoading
                ? const _LoadingView()
                : feed.errorMessage != null && routes.isEmpty
                ? _ErrorView(
                    message: feed.errorMessage!,
                    onRetry: store.refreshRoutes,
                  )
                : routes.isEmpty
                ? const _EmptyView(message: '좋아요한 루트가 없습니다.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    itemCount: routes.length + (feed.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= routes.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF3278),
                            ),
                          ),
                        );
                      }
                      final route = routes[index];
                      return _LikedRouteCard(
                        route: route,
                        onTap: () => _openRouteDetail(context, ref, route),
                        onToggle: () => store.toggleRouteLike(route.id),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _openRouteDetail(
    BuildContext context,
    WidgetRef ref,
    RouteModel route,
  ) async {
    final result = await context.push<bool>(
      AppRoutes.routeDetail,
      extra: route,
    );
    if (result == true && context.mounted) {
      await ref.read(myLikesStoreProvider.notifier).refreshRoutes();
    }
  }
}

class _LikedBouldersTab extends StatelessWidget {
  const _LikedBouldersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final feed = ref.watch(likedBoulderFeedProvider);
        final boulders = feed.items;
        final store = ref.read(myLikesStoreProvider.notifier);

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                feed.hasNext &&
                !feed.isLoadingMore) {
              store.loadMoreBoulders();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: store.refreshBoulders,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: feed.isInitialLoading
                ? const _LoadingView()
                : feed.errorMessage != null && boulders.isEmpty
                ? _ErrorView(
                    message: feed.errorMessage!,
                    onRetry: store.refreshBoulders,
                  )
                : boulders.isEmpty
                ? const _EmptyView(message: '좋아요한 바위가 없습니다.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    itemCount: boulders.length + (feed.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= boulders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF3278),
                            ),
                          ),
                        );
                      }
                      final boulder = boulders[index];
                      return _LikedBoulderCard(
                        boulder: boulder,
                        onTap: () => _openBoulderDetail(context, ref, boulder),
                        onToggle: () => store.toggleBoulderLike(boulder.id),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _openBoulderDetail(
    BuildContext context,
    WidgetRef ref,
    BoulderModel boulder,
  ) async {
    final result = await context.push<bool>(
      AppRoutes.boulderDetail,
      extra: boulder,
    );
    if (result == true && context.mounted) {
      await ref.read(myLikesStoreProvider.notifier).refreshBoulders();
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          message,
          style: const TextStyle(fontFamily: 'Pretendard', color: Colors.white),
        ),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _LikedRouteCard extends StatelessWidget {
  const _LikedRouteCard({
    required this.route,
    required this.onTap,
    required this.onToggle,
  });

  final RouteModel route;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: const Color(0xFF262A34),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${route.routeLevel} · ${route.province} ${route.city}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Color(0xFFB0B3B8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.person_2,
                      size: 14,
                      color: Color(0xFF9498A1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${route.climberCount}명 등반',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Color(0xFF9498A1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LikedBoulderCard extends StatelessWidget {
  const _LikedBoulderCard({
    required this.boulder,
    required this.onTap,
    required this.onToggle,
  });

  final BoulderModel boulder;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final location = boulder.city.isEmpty
        ? boulder.province
        : '${boulder.province} ${boulder.city}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: InkWell(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: const Color(0xFF262A34),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  boulder.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          boulder.liked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          size: 18,
                          color: boulder.liked
                              ? Colors.red
                              : const Color(0xFF9498A1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${boulder.likeCount}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          CupertinoIcons.eye,
                          size: 18,
                          color: Color(0xFF9498A1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${boulder.viewCount}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
