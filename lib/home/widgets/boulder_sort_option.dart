enum BoulderSortOption { latest, liked, popular }

extension BoulderSortOptionExtension on BoulderSortOption {
  String get name {
    switch (this) {
      case BoulderSortOption.latest:
        return 'latest';
      case BoulderSortOption.liked:
        return 'liked';
      case BoulderSortOption.popular:
        return 'popular';
    }
  }
}
