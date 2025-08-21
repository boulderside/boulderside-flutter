import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/route_model.dart';
import 'package:boulderside_flutter/home/services/boulder_service.dart';
import 'package:boulderside_flutter/home/services/route_service.dart';
import 'package:boulderside_flutter/home/widgets/boulder_card.dart';
import 'package:boulderside_flutter/home/widgets/route_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final BoulderService _boulderService = BoulderService();
  final RouteService _routeService = RouteService();

  List<BoulderModel> _allBoulders = [];
  List<RouteModel> _allRoutes = [];

  List<BoulderModel> _filteredBoulders = [];
  List<RouteModel> _filteredRoutes = [];

  bool _isLoading = true;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleQueryChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleQueryChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _boulderService.fetchBoulders(size: 30),
        _routeService.fetchBoulders(size: 30),
      ]);

      _allBoulders = results[0] as List<BoulderModel>;
      _allRoutes = results[1] as List<RouteModel>;

      _applyFilter();
    } catch (error) {
      // In a real app, show an error widget or snackbar
      _allBoulders = [];
      _allRoutes = [];
      _filteredBoulders = [];
      _filteredRoutes = [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleQueryChanged() {
    // While typing, show suggestions only (hide results)
    if (mounted) {
      setState(() {
        _hasSearched = false;
      });
    }
  }

  void _applyFilter() {
    final String query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredBoulders = _allBoulders;
        _filteredRoutes = _allRoutes;
      });
      return;
    }

    bool containsIgnoreCase(String target, String q) {
      return target.toLowerCase().contains(q);
    }

    final filteredBoulders = _allBoulders.where((boulder) {
      return containsIgnoreCase(boulder.name, query) ||
          containsIgnoreCase(boulder.location, query);
    }).toList();

    final filteredRoutes = _allRoutes.where((route) {
      return containsIgnoreCase(route.name, query) ||
          containsIgnoreCase(route.routeLevel, query);
    }).toList();

    setState(() {
      _filteredBoulders = filteredBoulders;
      _filteredRoutes = filteredRoutes;
    });
  }

  void _triggerSearch() {
    _applyFilter();
    if (mounted) {
      setState(() {
        _hasSearched = true;
      });
    }
  }

  List<String> _buildSuggestions() {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];

    final Set<String> pool = {
      ..._allBoulders.map((e) => e.name),
      ..._allRoutes.map((e) => e.name),
    };

    final suggestions = pool
        .where((name) => name.toLowerCase().contains(query))
        .take(10)
        .toList();

    // If no matches, propose the query itself
    if (suggestions.isEmpty) {
      return [ _searchController.text ];
    }
    return suggestions;
  }

  void _clearQuery() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    if (mounted) {
      setState(() {
        _hasSearched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _buildSuggestions();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: _SearchField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onClear: _clearQuery,
            onSearch: _triggerSearch,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '닫기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            )
          ],
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_hasSearched) ...[
              if (suggestions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF1E2129),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (s) => ActionChip(
                            label: Text(
                              s,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFF262A34),
                            onPressed: () {
                              _searchController.text = s;
                              _searchController.selection = TextSelection.fromPosition(
                                TextPosition(offset: s.length),
                              );
                              _triggerSearch();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  '키워드를 입력한 후 검색을 눌러 결과를 확인하세요',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Pretendard'
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 6),
              const _SearchTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
                      )
                    : TabBarView(
                        children: [
                          _RocksList(boulders: _filteredBoulders),
                          _RoutesList(routes: _filteredRoutes),
                          const _PlaceholderTab(text: 'Companions - Coming Soon'),
                          const _PlaceholderTab(text: 'Store - Coming Soon'),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
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
              icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFF9EA3AC), size: 18),
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

class _SearchTabs extends StatelessWidget {
  const _SearchTabs();

  @override
  Widget build(BuildContext context) {
    return TabBar(
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
        Tab(text: '바위'),
        Tab(text: '루트'),
        Tab(text: '동행'),
        Tab(text: '스토어'),
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
        return BoulderCard(boulder: boulders[index]);
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
        return RouteCard(route: routes[index]);
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String text;
  const _PlaceholderTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Pretendard'),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '결과가 없습니다',
        style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Pretendard',
        ),
      ),
    );
  }
}
