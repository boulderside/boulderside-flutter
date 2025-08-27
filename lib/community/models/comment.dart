class CommentModel {
  final String authorNickname;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.authorNickname,
    required this.content,
    required this.createdAt,
  });
}
