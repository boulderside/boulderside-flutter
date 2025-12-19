class CompletionResponse {
  const CompletionResponse({
    required this.completionId,
    required this.routeId,
    required this.userId,
    required this.routeName,
    required this.routeLevel,
    this.boulderName,
    required this.completedDate,
    this.memo,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  final int completionId;
  final int routeId;
  final int userId;
  final String routeName;
  final String routeLevel;
  final String? boulderName;
  final DateTime completedDate;
  final String? memo;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CompletionResponse.fromJson(Map<String, dynamic> json) {
    return CompletionResponse(
      completionId: _parseInt(json['completionId']),
      routeId: _parseInt(json['routeId']),
      userId: _parseInt(json['userId']),
      routeName: json['routeName'] as String? ?? '루트 #${json['routeId']}',
      routeLevel: json['routeLevel'] as String? ?? '정보 없음',
      boulderName: json['boulderName'] as String?,
      completedDate: _parseDate(json['completedDate']),
      memo: json['memo'] as String?,
      completed: json['completed'] == true,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}