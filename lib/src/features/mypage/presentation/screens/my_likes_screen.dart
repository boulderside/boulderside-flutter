import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/instagram.dart';
import 'package:boulderside_flutter/src/features/home/data/cache/route_index_cache.dart';
import 'package:boulderside_flutter/src/features/mypage/application/my_likes_store.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/liked_instagram_detail_screen.dart';
import 'package:boulderside_flutter/src/shared/widgets/segmented_toggle_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      store.loadInitialInstagrams();
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

enum _LikesSegment { boulders, routes, instagrams }

class _MyLikesBodyState extends State<_MyLikesBody> {
  static const Color _backgroundColor = Color(0xFF181A20);
  _LikesSegment _segment = _LikesSegment.boulders;

  @override
  Widget build(BuildContext context) {
    final Widget currentTab = switch (_segment) {
      _LikesSegment.boulders => const _LikedBouldersTab(),
      _LikesSegment.routes => const _LikedRoutesTab(),
      _LikesSegment.instagrams => const _LikedInstagramsTab(),
    };

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
                  SegmentOption(
                    label: '인스타그램',
                    value: _LikesSegment.instagrams,
                  ),
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
                      horizontal: 0,
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
                      horizontal: 0,
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

class _LikedInstagramsTab extends ConsumerStatefulWidget {
  const _LikedInstagramsTab();

  @override
  ConsumerState<_LikedInstagramsTab> createState() =>
      _LikedInstagramsTabState();
}

class _LikedInstagramsTabState extends ConsumerState<_LikedInstagramsTab> {
  late Future<List<RouteModel>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = di<RouteIndexCache>().load();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(likedInstagramFeedProvider);
    final instagrams = feed.items;
    final store = ref.read(myLikesStoreProvider.notifier);

    return FutureBuilder<List<RouteModel>>(
      future: _routesFuture,
      builder: (context, snapshot) {
        final routes = snapshot.data ?? const <RouteModel>[];
        final routeMap = {for (final route in routes) route.id: route};
        final hasRouteError = snapshot.hasError;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                feed.hasNext &&
                !feed.isLoadingMore) {
              store.loadMoreInstagrams();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              await store.refreshInstagrams();
              if (!mounted) return;
              setState(() {
                _routesFuture = di<RouteIndexCache>().refresh();
              });
            },
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: feed.isInitialLoading
                ? const _LoadingView()
                : feed.errorMessage != null && instagrams.isEmpty
                ? _ErrorView(
                    message: feed.errorMessage!,
                    onRetry: store.refreshInstagrams,
                  )
                : instagrams.isEmpty
                ? const _EmptyView(message: '좋아요한 인스타그램이 없습니다.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 0,
                    ),
                    itemCount:
                        instagrams.length +
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
                      if (itemIndex >= instagrams.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF3278),
                            ),
                          ),
                        );
                      }
                      final instagram = instagrams[itemIndex];
                      return _LikedInstagramCard(
                        instagram: instagram,
                        routeMap: routeMap,
                        onTap: () => _openInstagramDetail(context, instagram),
                        onToggle: () => store.toggleInstagramLike(instagram.id),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _openInstagramDetail(BuildContext context, Instagram instagram) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LikedInstagramDetailScreen(instagram: instagram),
      ),
    );
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
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _levelColor(
                          route.routeLevel,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        route.routeLevel,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        route.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.landscape_rounded,
                            size: 16,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              route.boulderName ?? '',
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
                          route.liked
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: route.liked
                              ? Colors.red
                              : const Color(0xFF9498A1),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.likeCount}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          CupertinoIcons.person_2,
                          size: 18,
                          color: Color(0xFF9498A1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.climberCount}',
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

  Color _levelColor(String level) {
    final normalized = level.trim().toUpperCase();
    int? numericLevel;
    final digitMatch = RegExp(r'(\d+)').firstMatch(normalized);
    if (digitMatch != null) {
      numericLevel = int.tryParse(digitMatch.group(1)!);
    } else if (normalized.contains('VB')) {
      numericLevel = 0;
    }

    if (numericLevel != null) {
      if (numericLevel <= 1) return const Color(0xFF4CAF50);
      if (numericLevel <= 3) return const Color(0xFFF2C94C);
      if (numericLevel <= 5) return const Color(0xFFF2994A);
      return const Color(0xFFE57373);
    }

    if (normalized.contains('초')) return const Color(0xFF4CAF50);
    if (normalized.contains('중')) return const Color(0xFFF2C94C);
    if (normalized.contains('상')) return const Color(0xFFE57373);
    return const Color(0xFF7E57C2);
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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

class _LikedInstagramCard extends StatelessWidget {
  const _LikedInstagramCard({
    required this.instagram,
    required this.routeMap,
    required this.onTap,
    required this.onToggle,
  });

  final Instagram instagram;
  final Map<int, RouteModel> routeMap;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final routeLabels = instagram.routeIds
        .map((id) => routeMap[id]?.name ?? '루트 #$id')
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2129),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2E333D)),
          ),
          child: _LikedInstagramCardContent(
            instagram: instagram,
            routeLabels: routeLabels,
            onToggle: onToggle,
            onDetail: onTap,
          ),
        ),
      ),
    );
  }
}

class _LikedInstagramCardContent extends StatefulWidget {
  const _LikedInstagramCardContent({
    required this.instagram,
    required this.routeLabels,
    required this.onToggle,
    required this.onDetail,
  });

  final Instagram instagram;
  final List<String> routeLabels;
  final VoidCallback onToggle;
  final VoidCallback onDetail;

  @override
  State<_LikedInstagramCardContent> createState() =>
      _LikedInstagramCardContentState();
}

class _LikedInstagramCardContentState
    extends State<_LikedInstagramCardContent> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            const Spacer(),
            GestureDetector(
              onTap: widget.onToggle,
              child: Icon(
                widget.instagram.liked
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                size: 18,
                color: widget.instagram.liked
                    ? Colors.red
                    : const Color(0xFF9498A1),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.instagram.likeCount}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
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
              '루트 ${widget.routeLabels.length}개',
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
            children: widget.routeLabels
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.onDetail,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF3278)),
              foregroundColor: const Color(0xFFFF3278),
            ),
            child: const Text(
              '상세보기',
              style: TextStyle(fontFamily: 'Pretendard'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
