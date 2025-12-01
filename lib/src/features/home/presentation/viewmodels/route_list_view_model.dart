import 'package:boulderside_flutter/src/features/home/data/models/route_model.dart';
import 'package:boulderside_flutter/src/features/home/data/models/route_page_response_model.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_sort_option.dart';
import 'package:flutter/foundation.dart';

class RouteListViewModel extends ChangeNotifier {
  final RouteService _service;

  RouteListViewModel(this._service);

  final List<RouteModel> routes = [];
  RouteSortOption currentSort = RouteSortOption.difficulty;

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
    routes.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;
    
    isLoading = true;
    notifyListeners();

    try {
      final RoutePageResponseModel page = await _service.fetchRoutes(
        routeSortType: currentSort.name,
        cursor: nextCursor,
        subCursor: nextSubCursor,
        size: pageSize,
      );
      
      routes.addAll(page.content);
      nextCursor = page.nextCursor;
      nextSubCursor = page.nextSubCursor;
      hasNext = page.hasNext;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 당겨서 새로고침 동일 동작
  Future<void> refresh() => loadInitial();

  /// 정렬 기준 변경
  void changeSort(RouteSortOption sort) async {
    if (currentSort == sort) return;
    currentSort = sort;
    await loadInitial();
  }
}