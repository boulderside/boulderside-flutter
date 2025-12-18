import 'package:boulderside_flutter/src/features/mypage/data/models/report_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  final ReportService _reportService = GetIt.I<ReportService>();
  final ScrollController _scrollController = ScrollController();
  final List<ReportResponse> _reports = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasNext = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasNext) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 0;
      _reports.clear();
      _hasNext = true;
    });
    await _fetchReports(reset: true);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNext) return;
    setState(() => _isLoadingMore = true);
    await _fetchReports(reset: false);
  }

  Future<void> _fetchReports({required bool reset}) async {
    try {
      final response = await _reportService.fetchMyReports(
        page: reset ? 0 : _currentPage,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _reports
            ..clear()
            ..addAll(response.content);
        } else {
          _reports.addAll(response.content);
        }
        _isLoading = false;
        _isLoadingMore = false;
        _hasNext = response.hasNext;
        _currentPage = response.page + 1;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = '신고 내역을 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '신고 내역',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFFF3278)),
            const SizedBox(height: 16),
            Text(
              '신고 내역을 불러오는 중...',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF5252),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '네트워크 연결을 확인하고\n다시 시도해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF3278), Color(0xFFFF1E5E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _loadInitial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '다시 시도',
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

    if (_reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '신고 내역이 없습니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '부적절한 콘텐츠를 발견하면\n언제든지 신고해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      color: const Color(0xFFFF3278),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _reports.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _reports.length) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFFF3278)),
                    const SizedBox(height: 12),
                    Text(
                      '추가 내역을 불러오는 중...',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final report = _reports[index];
          return _ReportTile(report: report);
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});

  final ReportResponse report;

  @override
  Widget build(BuildContext context) {
    final sections = _extractReasonSections(report.reason);
    final targetInfo = sections.targetInfo;
    final reasonText = sections.reason;
    final categoryLabel = report.category?.displayName;
    final hasTargetInfo = targetInfo != null && targetInfo.trim().isNotEmpty;
    final reasonBody = reasonText.isNotEmpty
        ? reasonText
        : '추가로 입력된 상세 사유가 없습니다.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    report.targetType.displayName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: report.status),
              ],
            ),
          ),
          // 콘텐츠 섹션
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categoryLabel != null) ...[
                  _InfoSection(
                    icon: Icons.category_outlined,
                    title: '신고 카테고리',
                    body: categoryLabel,
                  ),
                  const SizedBox(height: 12),
                ],
                if (hasTargetInfo) ...[
                  _InfoSection(
                    icon: Icons.info_outline,
                    title: '신고 대상 정보',
                    body: targetInfo,
                  ),
                  const SizedBox(height: 12),
                ],
                _InfoSection(
                  icon: Icons.description_outlined,
                  title: '신고 사유',
                  body: reasonBody,
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDate(report.createdAt),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}.$month.$day $hour:$minute';
  }

  ({String? targetInfo, String reason}) _extractReasonSections(String raw) {
    const targetHeader = '신고 대상 정보';
    const reasonHeader = '신고 사유';

    final targetIndex = raw.indexOf(targetHeader);
    final reasonIndex = raw.indexOf(reasonHeader);

    if (targetIndex != -1 && reasonIndex != -1 && targetIndex < reasonIndex) {
      final targetContentStart = targetIndex + targetHeader.length;
      final targetContent = raw
          .substring(targetContentStart, reasonIndex)
          .trim();
      final reasonContent = raw
          .substring(reasonIndex + reasonHeader.length)
          .trim();
      return (
        targetInfo: targetContent.isEmpty ? null : targetContent,
        reason: reasonContent.isEmpty ? raw.trim() : reasonContent,
      );
    }

    return (targetInfo: null, reason: raw.trim());
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = _mapStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, IconData) _mapStatus(String raw) {
    switch (raw) {
      case 'COMPLETED':
      case 'RESOLVED':
        return ('처리 완료', const Color(0xFF4CAF50), Icons.check_circle);
      case 'REJECTED':
      case 'DENIED':
        return ('반려됨', const Color(0xFFFF5252), Icons.cancel);
      default:
        return ('접수됨', const Color(0xFFFFC107), Icons.schedule);
    }
  }
}
