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
