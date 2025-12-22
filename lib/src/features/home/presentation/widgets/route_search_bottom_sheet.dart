import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/search/data/models/search_models.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
import 'package:flutter/material.dart';

class RouteSearchBottomSheet extends StatefulWidget {
  final List<RouteModel> alreadySelected;

  const RouteSearchBottomSheet({super.key, required this.alreadySelected});

  @override
  State<RouteSearchBottomSheet> createState() => _RouteSearchBottomSheetState();
}

class _RouteSearchBottomSheetState extends State<RouteSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  List<SearchItemResponse> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final response = await _searchService.searchByDomain(
        keyword: keyword,
        domain: DocumentDomainType.route,
        size: 20,
      );

      setState(() {
        _searchResults = response.items;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '검색에 실패했습니다';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2129),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '루트 검색',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '루트 이름으로 검색',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF262A34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                _performSearch(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF3278)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          '루트 이름을 입력해주세요',
          style: TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          '검색 결과가 없습니다',
          style: TextStyle(color: Colors.white70, fontFamily: 'Pretendard'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Color(0xFF262A34), height: 1),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final route = item.toRouteModel();
        final isAlreadySelected = widget.alreadySelected.any(
          (r) => r.id == route.id,
        );

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: Text(
            route.name,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: route.boulderName != null
              ? Text(
                  route.boulderName!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: isAlreadySelected
              ? const Icon(Icons.check_circle, color: Color(0xFFFF3278))
              : const Icon(Icons.add_circle_outline, color: Colors.white54),
          onTap: isAlreadySelected
              ? null
              : () {
                  Navigator.pop(context, route);
                },
        );
      },
    );
  }
}
