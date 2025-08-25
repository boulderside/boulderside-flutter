import 'package:boulderside_flutter/home/models/rec_boulder_model.dart';
import 'package:boulderside_flutter/home/models/rec_boulder_response_model.dart';
import 'package:boulderside_flutter/home/services/rec_boulder_service.dart';
import 'package:flutter/foundation.dart';

class RecBoulderListViewModel extends ChangeNotifier {
  final RecBoulderService _service;

  RecBoulderListViewModel(this._service);

  final List<RecBoulderModel> boulders = [];

  // 정렬 상태 고정
  final String sortType = 'LATEST';

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
      final RecBoulderResponseModel page = await _service.fetchBoulders(
        sortType: sortType, // LATEST
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
}
