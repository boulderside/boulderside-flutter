enum NotificationDomainType {
  notice('NOTICE'),
  boulder('BOULDER'),
  route('ROUTE'),
  instagram('INSTAGRAM'),
  matePost('MATE_POST'),
  boardPost('BOARD_POST');

  const NotificationDomainType(this.serverValue);

  final String serverValue;

  static NotificationDomainType fromServerValue(String? raw) {
    if (raw == null) {
      return NotificationDomainType.notice;
    }
    switch (raw.toUpperCase()) {
      case 'BOULDER':
        return NotificationDomainType.boulder;
      case 'ROUTE':
        return NotificationDomainType.route;
      case 'INSTAGRAM':
        return NotificationDomainType.instagram;
      case 'MATE_POST':
        return NotificationDomainType.matePost;
      case 'BOARD_POST':
        return NotificationDomainType.boardPost;
      default:
        return NotificationDomainType.notice;
    }
  }
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.domainType,
    required this.isRead,
    this.domainId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final NotificationDomainType domainType;
  final bool isRead;
  final String? domainId;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final domainType = NotificationDomainType.fromServerValue(
      json['domainType'] as String?,
    );
    final domainIdValue = json['domainId'] ?? json['noticeId'];
    final domainId = domainIdValue?.toString();
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      domainType: domainType,
      isRead: json['isRead'] as bool? ?? false,
      domainId: domainId,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    NotificationDomainType? domainType,
    String? domainId,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      domainType: domainType ?? this.domainType,
      domainId: domainId ?? this.domainId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'receivedAt': receivedAt.toIso8601String(),
    'domainType': domainType.serverValue,
    'domainId': domainId,
    'isRead': isRead,
  };
}
