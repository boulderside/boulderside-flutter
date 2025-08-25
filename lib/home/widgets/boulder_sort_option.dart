enum BoulderSortOption { latest, popular }

extension BoulderSortOptionExtension on BoulderSortOption {
  String get name {
    switch (this) {
      case BoulderSortOption.latest:
        return 'LATEST';
      case BoulderSortOption.popular:
        return 'POPULAR';
    }
  }
}
