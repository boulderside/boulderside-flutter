enum ReportTargetType {
  matePost('MATE_POST', '동행 글'),
  boardPost('BOARD_POST', '게시글'),
  comment('COMMENT', '댓글');

  const ReportTargetType(this.serverValue, this.displayName);

  final String serverValue;
  final String displayName;

  static ReportTargetType fromServerValue(String? value) {
    return ReportTargetType.values.firstWhere(
      (type) => type.serverValue == value,
      orElse: () => ReportTargetType.boardPost,
    );
  }
}
