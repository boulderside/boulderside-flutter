import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_boulders.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_boulders_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/boulder_sort_option.dart';
import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';

class BoulderListViewModel extends ChangeNotifier {
  final FetchBouldersUseCase _fetchBoulders;

  BoulderListViewModel(this._fetchBoulders);

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
    final Result<PaginatedBoulders> result = await _fetchBoulders(
      sortType: currentSort.name,
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

  void applyLikeResult(LikeToggleResult result) {
    final boulderId = result.boulderId ?? result.targetId;
    if (boulderId == null) return;
    final index = boulders.indexWhere((boulder) => boulder.id == boulderId);
    if (index == -1) return;
    final current = boulders[index];
    boulders[index] = current.copyWith(
      liked: result.liked ?? current.liked,
      likeCount: result.likeCount ?? current.likeCount,
    );
    notifyListeners();
  }
}
