class CommentModel {
  final String authorNickname;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.authorNickname,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      authorNickname: json['authorNickname'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorNickname': authorNickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
