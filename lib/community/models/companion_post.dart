class CompanionPost {
  final String title;
  final String meetingPlace;
  final String meetingDateLabel; // e.g., "2025.07.29 (Fri)"
  final String authorNickname;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final String? content;

  const CompanionPost({
    required this.title,
    required this.meetingPlace,
    required this.meetingDateLabel,
    required this.authorNickname,
    required this.commentCount,
    required this.viewCount,
    required this.createdAt,
    this.content,
  });
}
