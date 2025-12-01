import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/viewmodels/route_list_view_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/intro_text.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/route_detail_page.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_sort_option.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/sort_button.dart';
import 'package:boulderside_flutter/src/shared/utils/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteList extends StatelessWidget {
  const RouteList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RouteListViewModel(RouteService()),
      child: const _RouteListContent(),
    );
  }
}

class _RouteListContent extends StatefulWidget {
  const _RouteListContent();

  @override
  State<_RouteListContent> createState() => _RouteListContentState();
}

class _RouteListContentState extends State<_RouteListContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RouteListViewModel>(context, listen: false).loadInitial();
    });

    _scrollController.addListener(() {
      final viewModel = Provider.of<RouteListViewModel>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !viewModel.isLoading &&
          viewModel.hasNext) {
        viewModel.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteListViewModel>(
      builder: (context, viewModel, child) {
        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          backgroundColor: const Color(0xFF262A34),
          color: const Color(0xFFFF3278),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // 추천 바위 리스트
              const SizedBox(height: 10),
              const RecBoulderList(),

              // 텍스트
              const IntroText(),

              // 정렬 버튼
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
                child: Row(
                  children: [
                    SortButton(
                      text: '난이도순',
                      selected: viewModel.currentSort == RouteSortOption.difficulty,
                      onTap: () => viewModel.changeSort(RouteSortOption.difficulty),
                    ),
                    const SizedBox(width: 10),
                    SortButton(
                      text: '좋아요순',
                      selected: viewModel.currentSort == RouteSortOption.liked,
                      onTap: () => viewModel.changeSort(RouteSortOption.liked),
                    ),
                    const SizedBox(width: 10),
                    SortButton(
                      text: '동반자순',
                      selected: viewModel.currentSort == RouteSortOption.climbers,
                      onTap: () => viewModel.changeSort(RouteSortOption.climbers),
                    ),
                  ].divide(const SizedBox(width: 0)),
                ),
              ),

              // 루트 카드 리스트
              ...viewModel.routes.map(
                (route) => RouteCard(
                  route: route,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RouteDetailPage(route: route),
                      ),
                    );
                  },
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
