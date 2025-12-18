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
        title: const Text(
          '신고 내역',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 40),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadInitial,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Text(
          '신고한 내역이 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white54,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _reports.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _reports.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF262A34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.targetType.displayName,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _StatusChip(status: report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.reason,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDate(report.createdAt),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white38,
              fontSize: 12,
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
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _mapStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
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

  (String, Color) _mapStatus(String raw) {
    switch (raw) {
      case 'COMPLETED':
      case 'RESOLVED':
        return ('처리 완료', const Color(0xFF4CAF50));
      case 'REJECTED':
      case 'DENIED':
        return ('반려됨', const Color(0xFFFF5252));
      default:
        return ('접수됨', const Color(0xFFFFC107));
    }
  }
}
