import 'package:boulderside_flutter/src/features/mypage/data/models/report_category.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/report_target_type.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReportCreateArgs {
  ReportCreateArgs({
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
    this.contextInfo,
    this.contextSummary,
  });

  final ReportTargetType targetType;
  final int targetId;
  final String targetTitle;
  final String? contextInfo;
  final String? contextSummary;
}

class ReportCreateScreen extends StatefulWidget {
  const ReportCreateScreen({super.key, required this.args});

  final ReportCreateArgs args;

  @override
  State<ReportCreateScreen> createState() => _ReportCreateScreenState();
}

class _ReportCreateScreenState extends State<ReportCreateScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final ReportService _reportService = GetIt.I<ReportService>();
  ReportCategory? _selectedCategory;
  bool _submitting = false;
  String? _reasonError;
  String? _categoryError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetType = widget.args.targetType.displayName;
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '신고하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$targetType 신고',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '부적절한 콘텐츠를 신고해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (widget.args.contextSummary != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF262A34),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '신고 대상 정보',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.args.contextSummary!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildCategorySelector(),
            if (_selectedCategory == ReportCategory.other) ...[
              const SizedBox(height: 20),
              _buildReasonField(),
            ],
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3278), Color(0xFFFF1E5E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3278).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '신고 제출',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '신고 카테고리',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '해당되는 사유를 선택해주세요. 기타 선택 시에만 상세 사유를 입력할 수 있습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: ReportCategory.values.map((category) {
            final selected = _selectedCategory == category;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _categoryError = null;
                    if (category != ReportCategory.other) {
                      _reasonController.clear();
                      _reasonError = null;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF3278).withValues(alpha: 0.15)
                        : const Color(0xFF262A34),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF3278)
                          : Colors.white.withValues(alpha: 0.08),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: selected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_categoryError != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Color(0xFFFF6B6B),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _categoryError!,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF6B6B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3278).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Color(0xFFFF3278),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '상세 사유',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 6,
            maxLength: 2000,
            onChanged: (_) => setState(() => _reasonError = null),
            decoration: InputDecoration(
              hintText: '신고 사유를 상세히 입력해주세요.',
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              errorText: _reasonError,
              filled: true,
              fillColor: const Color(0xFF262A34),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFF3278),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
              counterStyle: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final category = _selectedCategory;
    final reasonText = _reasonController.text.trim();

    bool invalid = false;
    if (category == null) {
      _categoryError = '신고 카테고리를 선택해주세요.';
      invalid = true;
    }
    if (category == ReportCategory.other && reasonText.isEmpty) {
      _reasonError = '상세 사유를 입력해주세요.';
      invalid = true;
    }
    if (invalid) {
      setState(() {});
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '신고 제출',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '입력한 내용을 바탕으로 신고를 제출할까요?\n제출 후에는 취소할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF3278), Color(0xFFFF1E5E)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '신고',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() {
      _submitting = true;
      _categoryError = null;
      _reasonError = null;
    });
    try {
      String combinedReason;
      if (category == ReportCategory.other) {
        // 기타 선택 시 사용자가 입력한 내용 사용
        final detail = reasonText.isNotEmpty ? reasonText : '기타 사유로 신고합니다.';
        combinedReason = _buildReasonPayload(detail);
      } else {
        // 기타가 아닌 경우 빈 문자열
        combinedReason = '';
      }

      await _reportService.createReport(
        targetType: widget.args.targetType,
        targetId: widget.args.targetId,
        category: category!,
        reason: combinedReason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 접수에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  String _buildReasonPayload(String detail) {
    final buffer = StringBuffer();
    final contextInfo = widget.args.contextInfo?.trim();
    if (contextInfo != null && contextInfo.isNotEmpty) {
      buffer.writeln('신고 대상 정보');
      buffer.writeln(contextInfo);
      buffer.writeln();
    }
    buffer.writeln('신고 사유');
    buffer.writeln(detail);
    return buffer.toString().trim();
  }
}
