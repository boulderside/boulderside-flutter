enum BoulderSortOption { latest, popular }

extension BoulderSortOptionExtension on BoulderSortOption {
  String get name {
    switch (this) {
      case BoulderSortOption.latest:
        return 'LATEST_CREATED';
      case BoulderSortOption.popular:
        return 'MOST_LIKED';
    }
  }
}
