import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/domain/models/paginated_routes.dart';
import 'package:boulderside_flutter/src/features/home/domain/usecases/fetch_routes_use_case.dart';
import 'package:boulderside_flutter/src/features/home/presentation/widgets/route_sort_option.dart';
import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';

class RouteListViewModel extends ChangeNotifier {
  final FetchRoutesUseCase _fetchRoutes;

  RouteListViewModel(this._fetchRoutes);

  final List<RouteModel> routes = [];
  RouteSortOption currentSort = RouteSortOption.difficulty;

  int? nextCursor;
  String? nextSubCursor;
  bool hasNext = true;
  bool isLoading = false;
  String? errorMessage;
  final int pageSize = 5;

  /// 첫 페이지 로드(리셋 후 로드)
  Future<void> loadInitial() async {
    nextCursor = null;
    nextSubCursor = null;
    hasNext = true;
    errorMessage = null;
    routes.clear();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasNext) return;

    isLoading = true;
    notifyListeners();

    errorMessage = null;
    final Result<PaginatedRoutes> result = await _fetchRoutes(
      sortType: currentSort.name,
      cursor: nextCursor,
      subCursor: nextSubCursor,
      size: pageSize,
    );

    result.when(
      success: (page) {
        routes.addAll(page.items);
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
  void changeSort(RouteSortOption sort) async {
    if (currentSort == sort) return;
    currentSort = sort;
    await loadInitial();
  }

  void applyLikeResult(LikeToggleResult result) {
    final routeId = result.routeId ?? result.targetId;
    if (routeId == null) return;
    final index = routes.indexWhere((route) => route.id == routeId);
    if (index == -1) return;
    final current = routes[index];
    routes[index] = current.copyWith(
      liked: result.liked ?? current.liked,
      likeCount: result.likeCount ?? current.likeCount,
    );
    notifyListeners();
  }
}
