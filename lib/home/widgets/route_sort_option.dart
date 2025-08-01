enum RouteSortOption { difficulty, liked, climbers }

extension RouteSortOptionExtension on RouteSortOption {
  String get name {
    switch (this) {
      case RouteSortOption.difficulty:
        return 'difficulty';
      case RouteSortOption.liked:
        return 'liked';
      case RouteSortOption.climbers:
        return 'climbers';
    }
  }
}
