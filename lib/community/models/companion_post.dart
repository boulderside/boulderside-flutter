class CompanionPost {
  final int id;
  final String title;
  final String meetingPlace;
  final String meetingDateLabel; // e.g., "2025.07.29 (Fri)"
  final String authorNickname;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final String? content;

  const CompanionPost({
    required this.id,
    required this.title,
    required this.meetingPlace,
    required this.meetingDateLabel,
    required this.authorNickname,
    required this.commentCount,
    required this.viewCount,
    required this.createdAt,
    this.content,
  });

  factory CompanionPost.fromJson(Map<String, dynamic> json) {
    return CompanionPost(
      id: json['id'],
      title: json['title'],
      meetingPlace: json['meetingPlace'],
      meetingDateLabel: json['meetingDateLabel'],
      authorNickname: json['authorNickname'],
      commentCount: json['commentCount'],
      viewCount: json['viewCount'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
    );
  }
}
