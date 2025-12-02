import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_rec_boulders_use_case.dart';
import 'package:flutter/foundation.dart';

class RecBoulderListViewModel extends ChangeNotifier {
  final FetchRecBouldersUseCase _fetchRecBoulders;

  RecBoulderListViewModel(this._fetchRecBoulders);

  final List<BoulderModel> boulders = [];

  // 정렬 상태 고정
  final String boulderSortType = 'LATEST_CREATED';

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
    boulders.clear();
    errorMessage = null;
    await loadMore();
  }

  /// 당겨서 새로고침 동일 동작
  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _fetchRecBoulders(
        sortType: boulderSortType,
        cursor: nextCursor,
        subCursor: nextSubCursor,
        size: pageSize,
      );

      result.when(
        success: (page) {
          boulders.addAll(page.items);
          nextCursor = page.nextCursor;
          nextSubCursor = page.nextSubCursor;
          hasNext = page.hasNext;
        },
        failure: (failure) {
          errorMessage = failure.message;
        },
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
