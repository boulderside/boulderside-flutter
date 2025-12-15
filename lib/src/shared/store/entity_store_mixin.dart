/// Entity 정규화 패턴을 위한 Mixin
///
/// Store에서 entity map을 관리할 때 반복되는 패턴을 재사용합니다.
/// - Entity upsert (삽입/업데이트)
/// - ID 배열 병합 (페이지네이션)
mixin EntityStoreMixin<T, ID> {
  /// Entity Map에 여러 항목을 추가하거나 업데이트
  ///
  /// [current] 현재 entity map
  /// [items] 추가/업데이트할 항목들
  /// [getId] 각 항목에서 ID를 추출하는 함수
  ///
  /// Returns: 업데이트된 entity map
  Map<ID, T> upsertEntities(
    Map<ID, T> current,
    List<T> items,
    ID Function(T) getId,
  ) {
    if (items.isEmpty) return current;
    final updated = Map<ID, T>.from(current);
    for (final item in items) {
      updated[getId(item)] = item;
    }
    return updated;
  }

  /// ID 배열을 병합 (페이지네이션용)
  ///
  /// [existing] 기존 ID 배열
  /// [nextItems] 새로 추가할 항목들
  /// [getId] 각 항목에서 ID를 추출하는 함수
  /// [reset] true면 기존 배열을 무시하고 새로 시작
  ///
  /// Returns: 병합된 ID 배열 (중복 제거)
  List<ID> mergeIds(
    List<ID> existing,
    List<T> nextItems,
    ID Function(T) getId, {
    bool reset = false,
  }) {
    if (reset) {
      return nextItems.map(getId).toList();
    }

    final ids = List<ID>.from(existing);
    final seen = existing.toSet();

    for (final item in nextItems) {
      final id = getId(item);
      if (seen.add(id)) {
        ids.add(id);
      }
    }

    return ids;
  }

  /// ID 배열에서 특정 ID 제거
  ///
  /// [ids] 현재 ID 배열
  /// [idToRemove] 제거할 ID
  ///
  /// Returns: ID가 제거된 새 배열
  List<ID> removeId(List<ID> ids, ID idToRemove) {
    return ids.where((id) => id != idToRemove).toList();
  }
}