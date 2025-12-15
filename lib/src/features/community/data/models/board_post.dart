class BoardPost {
  final int id;
  final String title;
  final String authorNickname;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;
  final String? content;

  const BoardPost({
    required this.id,
    required this.title,
    required this.authorNickname,
    required this.commentCount,
    required this.viewCount,
    required this.createdAt,
    this.content,
  });

  BoardPost copyWith({
    int? id,
    String? title,
    String? authorNickname,
    int? commentCount,
    int? viewCount,
    DateTime? createdAt,
    String? content,
  }) {
    return BoardPost(
      id: id ?? this.id,
      title: title ?? this.title,
      authorNickname: authorNickname ?? this.authorNickname,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
    );
  }

  factory BoardPost.fromJson(Map<String, dynamic> json) {
    return BoardPost(
      id: json['id'],
      title: json['title'],
      authorNickname: json['authorNickname'],
      commentCount: json['commentCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authorNickname': authorNickname,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
    };
  }
}
