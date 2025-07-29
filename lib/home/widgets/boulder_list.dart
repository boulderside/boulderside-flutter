import 'package:boulderside_flutter/home/widgets/boulder_sort_button.dart';
import 'package:boulderside_flutter/home/widgets/boulder_sort_option.dart';
import 'package:boulderside_flutter/utils/widget_extensions.dart';
import 'package:flutter/material.dart';
import '../models/boulder_model.dart';
import '../services/boulder_service.dart';
import 'boulder_card.dart';

class BoulderList extends StatefulWidget {
  const BoulderList({super.key});

  @override
  State<BoulderList> createState() => _BoulderListState();
}

class _BoulderListState extends State<BoulderList> {
  final ScrollController _scrollController = ScrollController();
  final List<BoulderModel> _boulders = [];

  BoulderSortOption _currentSort = BoulderSortOption.latest;
  int? _cursorId;
  bool _isLoading = false;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await BoulderService().fetchBoulders(
        cursorId: _cursorId,
        size: _pageSize,
      );

      setState(() {
        _boulders.addAll(newItems);
        if (newItems.isNotEmpty) {
          _cursorId = newItems.last.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    _cursorId = null;
    _boulders.clear();
    await _loadMore();
  }

  /// 정렬 기준 변경
  void _changeSort(BoulderSortOption sort) {
    if (_currentSort != sort) {
      setState(() {
        _currentSort = sort;
      });
      _onRefresh();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
            child: Row(
              children: [
                BoulderSortButton(
                  text: '최신순',
                  selected: _currentSort == BoulderSortOption.latest,
                  onTap: () => _changeSort(BoulderSortOption.latest),
                ),
                const SizedBox(width: 10),
                BoulderSortButton(
                  text: '좋아요순',
                  selected: _currentSort == BoulderSortOption.liked,
                  onTap: () => _changeSort(BoulderSortOption.liked),
                ),
                const SizedBox(width: 10),
                BoulderSortButton(
                  text: '인기순',
                  selected: _currentSort == BoulderSortOption.popular,
                  onTap: () => _changeSort(BoulderSortOption.popular),
                ),
              ].divide(const SizedBox(width: 0)),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              backgroundColor: Color(0xFF262A34),
              color: Color(0xFFFF3278),
              child: ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _boulders.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _boulders.length) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF3278),
                        ),
                      ),
                    );
                  }

                  return BoulderCard(boulder: _boulders[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
