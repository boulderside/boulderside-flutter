enum ReportCategory {
  spam('SPAM', '스팸/홍보'),
  inappropriateContent('INAPPROPRIATE_CONTENT', '부적절한 내용'),
  harassmentOrAbuse('HARASSMENT_OR_ABUSE', '괴롭힘/욕설'),
  copyrightInfringement('COPYRIGHT_INFRINGEMENT', '저작권 침해'),
  misinformation('MISINFORMATION', '허위 정보'),
  safety('SAFETY', '안전 문제'),
  badManner('BAD_MANNER', '비매너'),
  other('OTHER', '기타');

  const ReportCategory(this.serverValue, this.displayName);

  final String serverValue;
  final String displayName;

  static ReportCategory? fromServerValue(String? value) {
    if (value == null) return null;
    return ReportCategory.values.firstWhere(
      (category) => category.serverValue == value,
      orElse: () => ReportCategory.other,
    );
  }
}
