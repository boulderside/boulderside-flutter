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

  CompanionPost copyWith({
    int? id,
    String? title,
    String? meetingPlace,
    String? meetingDateLabel,
    String? authorNickname,
    int? commentCount,
    int? viewCount,
    DateTime? createdAt,
    String? content,
  }) {
    return CompanionPost(
      id: id ?? this.id,
      title: title ?? this.title,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      meetingDateLabel: meetingDateLabel ?? this.meetingDateLabel,
      authorNickname: authorNickname ?? this.authorNickname,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }

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
