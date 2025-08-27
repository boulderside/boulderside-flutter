enum GeneralPostSortOption { latest, mostViewed }

extension GeneralPostSortOptionExtension on GeneralPostSortOption {
  String get name {
    switch (this) {
      case GeneralPostSortOption.latest:
        return 'latest';
      case GeneralPostSortOption.mostViewed:
        return 'mostViewed';
    }
  }

  String get displayText {
    switch (this) {
      case GeneralPostSortOption.latest:
        return '최신순';
      case GeneralPostSortOption.mostViewed:
        return '조회순';
    }
  }
}