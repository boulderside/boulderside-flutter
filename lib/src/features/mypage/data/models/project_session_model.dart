class ProjectSessionModel {
  const ProjectSessionModel({
    required this.sessionDate,
    required this.sessionCount,
  });

  final DateTime sessionDate;
  final int sessionCount;

  factory ProjectSessionModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['sessionDate'] ?? json['sessionDate'];
    return ProjectSessionModel(
      sessionDate: _parseDate(rawDate),
      sessionCount: _parseInt(json['sessionCount'] ?? json['sessionCount']),
    );
  }

  ProjectSessionModel copyWith({DateTime? sessionDate, int? sessionCount}) {
    return ProjectSessionModel(
      sessionDate: sessionDate ?? this.sessionDate,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionDate': _formatDateOnly(sessionDate),
      'sessionCount': sessionCount,
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
