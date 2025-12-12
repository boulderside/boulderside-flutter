class ProjectAttemptHistoryModel {
  const ProjectAttemptHistoryModel({
    required this.attemptedDate,
    required this.attemptCount,
  });

  final DateTime attemptedDate;
  final int attemptCount;

  factory ProjectAttemptHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['attemptedDate'];
    return ProjectAttemptHistoryModel(
      attemptedDate: _parseDate(rawDate),
      attemptCount: _parseInt(json['attemptCount']),
    );
  }

  ProjectAttemptHistoryModel copyWith({
    DateTime? attemptedDate,
    int? attemptCount,
  }) {
    return ProjectAttemptHistoryModel(
      attemptedDate: attemptedDate ?? this.attemptedDate,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'attemptedDate': _formatDateOnly(attemptedDate),
      'attemptCount': attemptCount,
    };
  }
}

DateTime _parseDate(dynamic raw) {
  if (raw == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
  if (raw is DateTime) {
    return raw;
  }
  return DateTime.tryParse(raw.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _formatDateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
