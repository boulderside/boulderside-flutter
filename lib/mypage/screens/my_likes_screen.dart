import 'package:boulderside_flutter/boulder/screens/boulder_detail.dart';
import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/screens/route_detail_page.dart';
import 'package:boulderside_flutter/home/widgets/boulder_card.dart';
import 'package:boulderside_flutter/home/widgets/route_card.dart';
import 'package:boulderside_flutter/mypage/services/my_likes_service.dart';
import 'package:boulderside_flutter/mypage/viewmodels/my_likes_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyLikesScreen extends StatelessWidget {
  const MyLikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyLikesViewModel>(
      create: (_) => MyLikesViewModel(MyLikesService())..loadLikes(),
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

        return RefreshIndicator(
          onRefresh: viewModel.refreshRoutes,
          backgroundColor: const Color(0xFF262A34),
          color: const Color(0xFFFF3278),
          child: isLoading
              ? const _LoadingView()
              : error != null
                  ? _ErrorView(
                      message: error,
                      onRetry: viewModel.refreshRoutes,
                    )
                  : routes.isEmpty
                      ? const _EmptyView(message: '좋아요한 루트가 없습니다.')
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: routes.length,
                          itemBuilder: (context, index) {
                            final route = routes[index];
                            return RouteCard(
                              route: route,
                              showChevron: true,
                              onTap: () => _openRouteDetail(context, route),
                            );
                          },
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

        return RefreshIndicator(
          onRefresh: viewModel.refreshBoulders,
          backgroundColor: const Color(0xFF262A34),
          color: const Color(0xFFFF3278),
          child: isLoading
              ? const _LoadingView()
              : error != null
                  ? _ErrorView(
                      message: error,
                      onRetry: viewModel.refreshBoulders,
                    )
                  : boulders.isEmpty
                      ? const _EmptyView(message: '좋아요한 바위가 없습니다.')
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 24),
                          itemCount: boulders.length,
                          itemBuilder: (context, index) {
                            final boulder = boulders[index];
                            return GestureDetector(
                              onTap: () => _openBoulderDetail(context, boulder),
                              child: BoulderCard(boulder: boulder),
                            );
                          },
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
