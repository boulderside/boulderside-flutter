import 'package:boulderside_flutter/home/models/boulder_model.dart';
import 'package:boulderside_flutter/home/models/boulder_page_response_model.dart';
import 'package:boulderside_flutter/home/services/boulder_service.dart';
import 'package:boulderside_flutter/home/widgets/boulder_sort_option.dart';
import 'package:flutter/foundation.dart';

class BoulderListViewModel extends ChangeNotifier {
  final BoulderService _service;

  BoulderListViewModel(this._service);

  final List<BoulderModel> boulders = [];
  BoulderSortOption currentSort = BoulderSortOption.latest;

  int? nextCursor; // nextCursor로 사용
  int? nextLikeCount; // nextLikeCount로 사용
  bool hasNext = true; // 페이지 끝인지 아닌지 판단
  bool isLoading = false;
  final int pageSize = 10;

  /// 첫 페이지 로드(리셋 후 로드)
  Future<void> loadInitial() async {
    nextCursor = null;
    nextLikeCount = null;
    hasNext = true;
    boulders.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;

    isLoading = true;
    notifyListeners();

    try {
      final BoulderPageResponseModel page = await _service.fetchBoulders(
        sortType: currentSort.name.toUpperCase(), // LATEST / POPULAR 등
        cursor: nextCursor,
        cursorLikeCount: nextLikeCount,
        size: pageSize,
      );

      boulders.addAll(page.content);
      nextCursor = page.nextCursor; // 서버가 준 nextCursor로 업데이트
      nextLikeCount = page.nextLikeCount; // 서버가 준 nextLikeCount로 업데이트
      hasNext = page.hasNext; // 더 가져올 수 있는지 체크
    } catch (e) {
      debugPrint('fetchBoulders error: $e');
    } finally {
      isLoading = false; // false로 내리기
      notifyListeners(); // 화면 갱신
    }
  }

  /// 당겨서 새로고침 동일 동작
  Future<void> refresh() => loadInitial();

  /// 정렬 기준 변경
  void changeSort(BoulderSortOption sort) async {
    if (currentSort == sort) return;
    currentSort = sort;
    await loadInitial(); // (커서 값, 바위 리스트 리셋) + 첫 페이지 재요청
  }
}
