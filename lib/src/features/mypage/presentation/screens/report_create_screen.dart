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
  final TextEditingController _controller = TextEditingController();
  final ReportService _reportService = GetIt.I<ReportService>();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
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
        title: const Text(
          '신고하기',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
            const SizedBox(height: 8),
            if (widget.args.contextSummary != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF262A34),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '신고 대상 정보',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.args.contextSummary!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 8,
              maxLength: 2000,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: '신고 사유를 입력해주세요. (최대 2000자)',
                hintStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white54,
                ),
                errorText: _error,
                filled: true,
                fillColor: const Color(0xFF262A34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                counterStyle: const TextStyle(color: Colors.white54),
              ),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '신고 제출',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = '신고 사유를 입력해주세요.');
      return;
    }
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF262A34),
            title: const Text(
              '신고 제출',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
              ),
            ),
            content: const Text(
              '입력한 내용을 바탕으로 신고를 제출할까요?\n제출 후에는 취소할 수 없습니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white54,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  '신고',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Color(0xFFFF3278),
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final combinedReason = widget.args.contextInfo == null
          ? reason
          : '신고 대상 정보\n${widget.args.contextInfo}\n\n신고 사유\n$reason';

      await _reportService.createReport(
        targetType: widget.args.targetType,
        targetId: widget.args.targetId,
        reason: combinedReason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고가 접수되었습니다.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고 접수에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }
}
