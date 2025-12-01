import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/general_post_sort_option.dart';

class BoardPostListViewModel extends ChangeNotifier {
  final BoardPostService _service;

  BoardPostListViewModel(this._service);

  final List<BoardPost> posts = [];
  GeneralPostSortOption currentSort = GeneralPostSortOption.latest;

  int? nextCursor;
  String? nextSubCursor;
  bool hasNext = true;
  bool isLoading = false;
  final int pageSize = 5;

  /// 첫 페이지 로드(리셋 후 로드)
  Future<void> loadInitial() async {
    nextCursor = null;
    nextSubCursor = null;
    hasNext = true;
    posts.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;
    
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.fetchPosts(
        cursor: nextCursor,
        subCursor: nextSubCursor,
        size: pageSize,
        sort: _getSort(currentSort),
      );
      
      posts.addAll(response.content.map((post) => post.toBoardPost()));
      nextCursor = response.nextCursor;
      nextSubCursor = response.nextSubCursor;
      hasNext = response.hasNext;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 당겨서 새로고침 동일 동작
  Future<void> refresh() => loadInitial();

  /// 정렬 기준 변경
  void changeSort(GeneralPostSortOption sort) async {
    if (currentSort == sort) return;
    currentSort = sort;
    await loadInitial(); // (커서 값, 포스트 리스트 리셋) + 첫 페이지 재요청
  }

  BoardPostSort _getSort(GeneralPostSortOption sort) {
    switch (sort) {
      case GeneralPostSortOption.latest:
        return BoardPostSort.latestCreated;
      case GeneralPostSortOption.mostViewed:
        return BoardPostSort.mostViewed;
    }
  }
}
