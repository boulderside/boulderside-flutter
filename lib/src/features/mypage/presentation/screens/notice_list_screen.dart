import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/notice_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/notice_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'notice_detail_screen.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  final NoticeService _noticeService = GetIt.I<NoticeService>();
  final ScrollController _scrollController = ScrollController();
  final List<NoticeResponse> _notices = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasNext = true;
  int _currentPage = 0;
  static const int _pageSize = 10;
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
      _hasNext = true;
      _notices.clear();
    });
    await _fetchNotices(reset: true);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNext) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });
    await _fetchNotices(reset: false);
  }

  Future<void> _fetchNotices({required bool reset}) async {
    try {
      final response = await _noticeService.fetchNotices(
        page: reset ? 0 : _currentPage,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _notices
            ..clear()
            ..addAll(response.content);
        } else {
          _notices.addAll(response.content);
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
        _error = '공지사항을 불러오지 못했습니다.';
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
          '공지사항',
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
            ElevatedButton(onPressed: _loadInitial, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    if (_notices.isEmpty) {
      return const Center(
        child: Text(
          '등록된 공지사항이 없습니다.',
          style: TextStyle(fontFamily: 'Pretendard', color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _notices.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _notices.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final notice = _notices[index];
          return _NoticeTile(
            notice: notice,
            onTap: () => context.push(
              AppRoutes.noticeDetail,
              extra: NoticeDetailArgs(noticeId: notice.id, notice: notice),
            ),
          );
        },
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.notice, required this.onTap});

  final NoticeResponse notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      onTap: onTap,
      title: Row(
        children: [
          if (notice.pinned)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3278).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '공지',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF3278),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            child: Text(
              notice.title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          _formatDate(notice.createdAt),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
        size: 20,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}
