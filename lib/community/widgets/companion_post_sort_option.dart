enum CompanionPostSortOption { latest, mostViewed, companionDate }

extension CompanionPostSortOptionExtension on CompanionPostSortOption {
  String get name {
    switch (this) {
      case CompanionPostSortOption.latest:
        return 'latest';
      case CompanionPostSortOption.mostViewed:
        return 'mostViewed';
      case CompanionPostSortOption.companionDate:
        return 'companionDate';
    }
  }

  String get displayText {
    switch (this) {
      case CompanionPostSortOption.latest:
        return '최신순';
      case CompanionPostSortOption.mostViewed:
        return '조회순';
      case CompanionPostSortOption.companionDate:
        return '동행날짜순';
    }
  }
}