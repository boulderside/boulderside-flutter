import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/features/home/data/models/rec_boulder_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/rec_boulder_response_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:flutter/foundation.dart';

class RecBoulderListViewModel extends ChangeNotifier {
  final RecBoulderService _service;

  RecBoulderListViewModel(this._service);

  final List<RecBoulderModel> boulders = [];

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

    final Result<RecBoulderResponseModel> result =
        await _service.fetchBoulders(
      boulderSortType: boulderSortType,
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
}
