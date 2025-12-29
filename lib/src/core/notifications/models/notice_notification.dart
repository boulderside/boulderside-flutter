class NoticeNotification {
  NoticeNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.noticeId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String? noticeId;

  factory NoticeNotification.fromJson(Map<String, dynamic> json) {
    return NoticeNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      noticeId: json['noticeId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'receivedAt': receivedAt.toIso8601String(),
    'noticeId': noticeId,
  };
}
