import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/models/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/boulder_page_response_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:flutter/foundation.dart';

class BoulderListViewModel extends ChangeNotifier {
  final BoulderService _service;

  BoulderListViewModel(this._service);

  final List<BoulderModel> boulders = [];
  BoulderSortOption currentSort = BoulderSortOption.latest;

  int? nextCursor; // nextCursor로 사용
  String? nextSubCursor; // nextSubCursor로 사용
  bool hasNext = true; // 페이지 끝인지 아닌지 판단
  bool isLoading = false;
  String? errorMessage;
  final int pageSize = 5;

  /// 첫 페이지 로드(리셋 후 로드)
  Future<void> loadInitial() async {
    nextCursor = null;
    nextSubCursor = null;
    hasNext = true;
    errorMessage = null;
    boulders.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;
    
    isLoading = true;
    notifyListeners();

    errorMessage = null;
    final Result<BoulderPageResponseModel> result = await _service.fetchBoulders(
      boulderSortType: currentSort.name,
      cursor: nextCursor,
      subCursor: nextSubCursor,
      size: pageSize,
    );

    result.when(
      success: (page) {
        boulders.addAll(page.content);
        nextCursor = page.nextCursor;
        nextSubCursor = page.nextSubCursor;
        hasNext = page.hasNext;
      },
      failure: (failure) {
        errorMessage = failure.message;
      },
    );

    isLoading = false;
    notifyListeners();
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
