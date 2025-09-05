import 'package:flutter/foundation.dart';
import '../models/board_post.dart';
import '../models/post_models.dart';
import '../services/post_service.dart';
import '../widgets/general_post_sort_option.dart';

class BoardPostListViewModel extends ChangeNotifier {
  final PostService _service;

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
      final response = await _service.getPostPage(
        cursor: nextCursor,
        subCursor: nextSubCursor,
        size: pageSize,
        postType: PostType.board,
        postSortType: _getPostSortType(currentSort),
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

  PostSortType _getPostSortType(GeneralPostSortOption sort) {
    switch (sort) {
      case GeneralPostSortOption.latest:
        return PostSortType.latestCreated;
      case GeneralPostSortOption.mostViewed:
        return PostSortType.mostViewed;
    }
  }
}