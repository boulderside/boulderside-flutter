import 'package:boulderside_flutter/src/features/mypage/data/models/notice_response.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/notice_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NoticeDetailArgs {
  NoticeDetailArgs({required this.noticeId, this.notice});

  final int noticeId;
  final NoticeResponse? notice;
}

class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({super.key, required this.args});

  final NoticeDetailArgs args;

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  final NoticeService _noticeService = GetIt.I<NoticeService>();
  NoticeResponse? _notice;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notice = widget.args.notice;
    if (_notice != null) {
      _isLoading = false;
    }
    _fetchNotice();
  }

  Future<void> _fetchNotice() async {
    try {
      setState(() {
        _error = null;
        _isLoading = _notice == null;
      });
      final response = await _noticeService.fetchNotice(widget.args.noticeId);
      if (!mounted) return;
      setState(() {
        _notice = response;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '공지사항을 불러오지 못했습니다.';
        _isLoading = false;
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
            ElevatedButton(onPressed: _fetchNotice, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final notice = _notice!;
    return RefreshIndicator(
      onRefresh: _fetchNotice,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDateTime(notice.createdAt),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                notice.content,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.year}.$month.$day $hour:$minute';
  }
}
