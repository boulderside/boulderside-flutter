class CompletionRequest {
  const CompletionRequest({
    required this.routeId,
    required this.completedDate,
    this.memo,
    this.completed = true,
  });

  final int routeId;
  final DateTime completedDate;
  final String? memo;
  final bool completed;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'routeId': routeId,
      'completedDate': _formatDateOnly(completedDate),
      'completed': completed,
      if (memo != null && memo!.trim().isNotEmpty) 'memo': memo!.trim(),
    };
  }
}

String _formatDateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
