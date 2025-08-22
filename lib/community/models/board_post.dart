class BoardPost {
  final String title;
  final String authorNickname;
  final int commentCount;
  final int viewCount;
  final DateTime createdAt;

  const BoardPost({
    required this.title,
    required this.authorNickname,
    required this.commentCount,
    required this.viewCount,
    required this.createdAt,
  });
}
