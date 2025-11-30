import 'package:boulderside_flutter/boulder/screens/boulder_detail.dart';
import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/screens/route_detail_page.dart';
import 'package:boulderside_flutter/mypage/services/my_likes_service.dart';
import 'package:boulderside_flutter/mypage/viewmodels/my_likes_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyLikesScreen extends StatelessWidget {
  const MyLikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyLikesViewModel>(
      create: (_) => MyLikesViewModel(MyLikesService())..loadInitial(),
      child: const _MyLikesBody(),
    );
  }
}

class _MyLikesBody extends StatelessWidget {
  const _MyLikesBody();

  static const Color _backgroundColor = Color(0xFF181A20);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text(
            '나의 좋아요',
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
          bottom: const TabBar(
            tabs: [
              Tab(text: '루트'),
              Tab(text: '바위'),
            ],
            indicatorColor: Color(0xFFFF3278),
            labelStyle: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _LikedRoutesTab(),
            _LikedBouldersTab(),
          ],
        ),
      ),
    );
  }
}

class _LikedRoutesTab extends StatelessWidget {
  const _LikedRoutesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MyLikesViewModel>(
      builder: (context, viewModel, _) {
        final isLoading = viewModel.isLoadingRoutes;
        final error = viewModel.routeError;
        final routes = viewModel.routes;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                viewModel.routeHasNext &&
                !viewModel.isLoadingMoreRoutes) {
              viewModel.loadMoreRoutes();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: viewModel.refreshRoutes,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: isLoading && routes.isEmpty
                ? const _LoadingView()
                : error != null && routes.isEmpty
                    ? _ErrorView(
                        message: error,
                        onRetry: viewModel.refreshRoutes,
                      )
                    : routes.isEmpty
                        ? const _EmptyView(message: '좋아요한 루트가 없습니다.')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            itemCount: routes.length +
                                (viewModel.isLoadingMoreRoutes ? 1 : 0),
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
                                onTap: () => _openRouteDetail(context, route),
                                onToggle: () =>
                                    viewModel.toggleRouteLike(route.id),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }

  void _openRouteDetail(BuildContext context, RouteModel route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RouteDetailPage(route: route),
      ),
    );
  }
}

class _LikedBouldersTab extends StatelessWidget {
  const _LikedBouldersTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MyLikesViewModel>(
      builder: (context, viewModel, _) {
        final isLoading = viewModel.isLoadingBoulders;
        final error = viewModel.boulderError;
        final boulders = viewModel.boulders;

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200 &&
                viewModel.boulderHasNext &&
                !viewModel.isLoadingMoreBoulders) {
              viewModel.loadMoreBoulders();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: viewModel.refreshBoulders,
            backgroundColor: const Color(0xFF262A34),
            color: const Color(0xFFFF3278),
            child: isLoading && boulders.isEmpty
                ? const _LoadingView()
                : error != null && boulders.isEmpty
                    ? _ErrorView(
                        message: error,
                        onRetry: viewModel.refreshBoulders,
                      )
                    : boulders.isEmpty
                        ? const _EmptyView(message: '좋아요한 바위가 없습니다.')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            itemCount: boulders.length +
                                (viewModel.isLoadingMoreBoulders ? 1 : 0),
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
                                onTap: () =>
                                    _openBoulderDetail(context, boulder),
                                onToggle: () =>
                                    viewModel.toggleBoulderLike(boulder.id),
                              );
                            },
                          ),
          ),
        );
      },
    );
  }

  void _openBoulderDetail(BuildContext context, BoulderModel boulder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BoulderDetail(boulder: boulder),
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
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('다시 시도'),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: onToggle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${route.routeLevel} · ${route.province} ${route.city}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(${route.climberCount}명 등반)',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFF9498A1),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      boulder.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: onToggle,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '좋아요 ${boulder.likeCount}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFF9498A1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
