enum RouteSortOption { difficulty, liked, climbers }

extension RouteSortOptionExtension on RouteSortOption {
  String get name {
    switch (this) {
      case RouteSortOption.difficulty:
        return 'DIFFICULTY';
      case RouteSortOption.liked:
        return 'MOST_LIKED';
      case RouteSortOption.climbers:
        return 'MOST_CLIMBERS';
    }
  }
}
