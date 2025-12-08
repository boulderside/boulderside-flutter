import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_card.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_card.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_card.dart';
import 'package:boulderside_flutter/src/features/search/data/models/search_models.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
import 'package:boulderside_flutter/src/features/search/presentation/viewmodels/search_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(context.read<SearchService>()),
      child: const _SearchPageContent(),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  const _SearchPageContent();

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _searchController.addListener(_handleQueryChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_handleQueryChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      final newIndex = _tabController.index;
      final viewModel = Provider.of<SearchViewModel>(context, listen: false);
      if (newIndex != _currentTabIndex &&
          viewModel.state == SearchState.completed) {
        _currentTabIndex = newIndex;
        _performSearchForCurrentTab();
      }
    }
  }

  void _handleQueryChanged() {
    if (mounted) {
      final viewModel = Provider.of<SearchViewModel>(context, listen: false);
      viewModel.updateQuery(_searchController.text.trim());
    }
  }

  Future<void> _performUnifiedSearch() async {
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    await viewModel.searchUnified();
  }

  Future<void> _performDomainSearch(DocumentDomainType domain) async {
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    await viewModel.searchByDomain(domain: domain);
  }

  Future<void> _performSearchForCurrentTab() async {
    switch (_currentTabIndex) {
      case 0: // 통합 tab
        await _performUnifiedSearch();
        break;
      case 1: // 바위 tab
        await _performDomainSearch(DocumentDomainType.boulder);
        break;
      case 2: // 루트 tab
        await _performDomainSearch(DocumentDomainType.route);
        break;
      case 3: // 동행 tab
        await _performDomainSearch(DocumentDomainType.post);
        break;
    }
  }

  void _triggerSearch() {
    FocusScope.of(context).unfocus();
    _currentTabIndex = 0;
    _tabController.animateTo(0);
    _performUnifiedSearch();
  }

  void _clearQuery() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        final hasSearched =
            viewModel.state == SearchState.completed ||
            viewModel.state == SearchState.searching;
        final suggestions = viewModel.suggestions;
        final isLoadingSuggestions = viewModel.isLoadingSuggestions;
        final isLoading = viewModel.isLoading;

        // Extract data from unified results
        final unifiedBoulders =
            viewModel
                .unifiedResults
                ?.domainResults[DocumentDomainType.boulder]
                ?.items
                .map((item) => item.toBoulderModel())
                .toList() ??
            <BoulderModel>[];
        final unifiedRoutes =
            viewModel
                .unifiedResults
                ?.domainResults[DocumentDomainType.route]
                ?.items
                .map((item) => item.toRouteModel())
                .toList() ??
            <RouteModel>[];
        final unifiedCompanions =
            viewModel
                .unifiedResults
                ?.domainResults[DocumentDomainType.post]
                ?.items
                .map((item) => item.toCompanionPost())
                .toList() ??
            <CompanionPost>[];

        // Extract data from domain results
        final domainBoulders =
            viewModel.domainResults[DocumentDomainType.boulder]?.items
                .map((item) => item.toBoulderModel())
                .toList() ??
            <BoulderModel>[];
        final domainRoutes =
            viewModel.domainResults[DocumentDomainType.route]?.items
                .map((item) => item.toRouteModel())
                .toList() ??
            <RouteModel>[];
        final domainCompanions =
            viewModel.domainResults[DocumentDomainType.post]?.items
                .map((item) => item.toCompanionPost())
                .toList() ??
            <CompanionPost>[];

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFF181A20),
          appBar: AppBar(
            backgroundColor: const Color(0xFF181A20),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: _SearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onClear: _clearQuery,
              onSearch: _triggerSearch,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  '닫기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!hasSearched) ...[
                if (suggestions.isNotEmpty || isLoadingSuggestions)
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 3, 16, 0),
                      color: const Color(0xFF1E2129),
                      child: isLoadingSuggestions
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF3278),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: suggestions.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final s = suggestions[index];
                                return _SuggestionListItem(
                                  text: s,
                                  isLast: index == suggestions.length - 1,
                                  onTap: () {
                                    _searchController.text = s;
                                    viewModel.selectSuggestion(s);
                                    _searchController.selection =
                                        TextSelection.fromPosition(
                                          TextPosition(offset: s.length),
                                        );
                                    _triggerSearch();
                                  },
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    color: Color(0xFF2C313A),
                                    height: 1,
                                    thickness: 1,
                                  ),
                            ),
                    ),
                  ),
                if (_searchController.text.trim().isEmpty) ...[
                  const SizedBox(height: 3),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Text(
                      '키워드를 입력한 후 검색을 눌러 결과를 확인하세요',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 6),
                _SearchTabs(controller: _tabController),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF3278),
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _AllResultsList(
                              boulders: unifiedBoulders,
                              routes: unifiedRoutes,
                              companions: unifiedCompanions,
                              onNavigateToTab: (int tabIndex) {
                                _currentTabIndex = tabIndex;
                                _tabController.animateTo(tabIndex);
                                _performSearchForCurrentTab();
                              },
                            ),
                            _RocksList(boulders: domainBoulders),
                            _RoutesList(routes: domainRoutes),
                            _CompanionsList(companions: domainCompanions),
                          ],
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final VoidCallback onSearch;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.search, color: Color(0xFF9EA3AC), size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: TextStyle(
                  color: Color(0xFF9EA3AC),
                  fontFamily: 'Pretendard',
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
                onSearch();
              },
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Color(0xFF9EA3AC),
                size: 18,
              ),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          else
            const SizedBox(width: 8),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SuggestionListItem extends StatelessWidget {
  final String text;
  final bool isLast;
  final VoidCallback onTap;

  const _SuggestionListItem({
    required this.text,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: isLast ? 6 : 10),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              color: Color(0xFF9EA3AC),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTabs extends StatelessWidget {
  final TabController controller;

  const _SearchTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white,
      labelStyle: const TextStyle(
        fontFamily: 'Pretendard',
        letterSpacing: 0.0,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
      indicatorColor: const Color(0xFFFF3278),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: const [
        Tab(text: '통합'),
        Tab(text: '바위'),
        Tab(text: '루트'),
        Tab(text: '동행'),
      ],
    );
  }
}

class _RocksList extends StatelessWidget {
  final List<BoulderModel> boulders;

  const _RocksList({required this.boulders});

  @override
  Widget build(BuildContext context) {
    if (boulders.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      itemCount: boulders.length,
      itemBuilder: (context, index) {
        final boulder = boulders[index];
        return GestureDetector(
          onTap: () => context.push(AppRoutes.boulderDetail, extra: boulder),
          child: BoulderCard(boulder: boulder),
        );
      },
    );
  }
}

class _RoutesList extends StatelessWidget {
  final List<RouteModel> routes;

  const _RoutesList({required this.routes});

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return RouteCard(
          route: route,
          onTap: () => context.push(AppRoutes.routeDetail, extra: route),
        );
      },
    );
  }
}

class _AllResultsList extends StatelessWidget {
  final List<BoulderModel> boulders;
  final List<RouteModel> routes;
  final List<CompanionPost> companions;
  final Function(int) onNavigateToTab;

  const _AllResultsList({
    required this.boulders,
    required this.routes,
    required this.companions,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBoulders = boulders.isNotEmpty;
    final bool hasRoutes = routes.isNotEmpty;
    final bool hasCompanions = companions.isNotEmpty;

    if (!hasBoulders && !hasRoutes && !hasCompanions) {
      return const _EmptyView();
    }

    final List<Widget> children = [];

    if (hasBoulders) {
      final bool showSeeMore = boulders.isNotEmpty;
      children.add(const _SectionHeader(title: '바위'));
      for (final b in boulders.take(3)) {
        children.add(
          GestureDetector(
            onTap: () => context.push(AppRoutes.boulderDetail, extra: b),
            child: BoulderCard(boulder: b),
          ),
        );
      }
      if (showSeeMore) {
        children.add(
          _SectionFooterSeeMore(
            label: '바위 전체보기',
            onPressed: () {
              onNavigateToTab(1); // Navigate to '바위' tab
            },
          ),
        );
      }
      children.add(const SizedBox(height: 8));
    }

    if (hasRoutes) {
      final bool showSeeMore = routes.isNotEmpty;
      children.add(const _SectionHeader(title: '루트'));
      for (final r in routes.take(3)) {
        children.add(
          RouteCard(
            route: r,
            onTap: () => context.push(AppRoutes.routeDetail, extra: r),
          ),
        );
      }
      if (showSeeMore) {
        children.add(
          _SectionFooterSeeMore(
            label: '루트 전체보기',
            onPressed: () {
              onNavigateToTab(2); // Navigate to '루트' tab
            },
          ),
        );
      }
      children.add(const SizedBox(height: 8));
    }

    if (hasCompanions) {
      final bool showSeeMore = companions.isNotEmpty;
      children.add(const _SectionHeader(title: '동행'));
      for (final c in companions.take(3)) {
        children.add(CompanionPostCard(post: c));
      }
      if (showSeeMore) {
        children.add(
          _SectionFooterSeeMore(
            label: '동행 전체보기',
            onPressed: () {
              onNavigateToTab(3); // Navigate to '동행' tab
            },
          ),
        );
      }
      children.add(const SizedBox(height: 8));
    }

    return ListView(children: children);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _SectionFooterSeeMore extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SectionFooterSeeMore({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionsList extends StatelessWidget {
  final List<CompanionPost> companions;

  const _CompanionsList({required this.companions});

  @override
  Widget build(BuildContext context) {
    if (companions.isEmpty) {
      return const _EmptyView();
    }

    return ListView.builder(
      itemCount: companions.length,
      itemBuilder: (context, index) {
        return CompanionPostCard(post: companions[index]);
      },
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '검색 결과가 없습니다',
        style: TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
      ),
    );
  }
}
