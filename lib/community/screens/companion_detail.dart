import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/companion_post.dart';

class CompanionDetailPage extends StatefulWidget {
  final CompanionPost? post;
  const CompanionDetailPage({super.key, this.post});

  @override
  State<CompanionDetailPage> createState() => _CompanionDetailPageState();
}

class _CompanionDetailPageState extends State<CompanionDetailPage> {
  bool _isMenuOpen = false;

  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inMinutes < 1) return '방금 전';
    if (duration.inHours < 1) return '${duration.inMinutes}분 전';
    if (duration.inDays < 1) return '${duration.inHours}시간 전';
    if (duration.inDays < 7) return '${duration.inDays}일 전';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post ?? CompanionPost(
      id: 0, // Fallback ID for demo
      title: '동행 상세',
      meetingPlace: '서울특별시',
      meetingDateLabel: '2025.08.02 (Sat)',
      authorNickname: 'guest',
      commentCount: 0,
      viewCount: 0,
      createdAt: DateTime.now(),
      content: '동행 글 내용이 없습니다.',
    );

    // TODO: Replace with real current user nickname from auth/session
    final String currentNickname = 'me';
    final bool isAuthor = post.authorNickname == currentNickname;

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('동행 글', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
            onOpened: () => setState(() => _isMenuOpen = true),
            onCanceled: () {
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!mounted) return;
                setState(() => _isMenuOpen = false);
              });
            },
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Post tapped')),
                  );
                  break;
                case 'delete':
                  final messenger = ScaffoldMessenger.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text('Are you sure you want to delete this post?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Post deleted')),
                    );
                  }
                  break;
                case 'report':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report Post tapped')),
                  );
                  break;
              }
              Future.delayed(const Duration(milliseconds: 150), () {
                if (!mounted) return;
                setState(() => _isMenuOpen = false);
              });
            },
            itemBuilder: (context) {
              if (isAuthor) {
                return const [
                  PopupMenuItem(value: 'edit', child: Text('Edit Post')),
                  PopupMenuItem(value: 'delete', child: Text('Delete Post')),
                ];
              } else {
                return const [
                  PopupMenuItem(value: 'report', child: Text('Report Post')),
                ];
              }
            },
          ),
        ],
      ),
      body: IgnorePointer(
        ignoring: _isMenuOpen,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
          Card(
            color: const Color(0xFF262A34),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.calendar, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 6),
                      Text(post.meetingDateLabel, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.person_fill, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 6),
                      Text(post.authorNickname, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(width: 12),
                      const Icon(CupertinoIcons.eye, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 4),
                      Text('${post.viewCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      const SizedBox(width: 12),
                      const Icon(CupertinoIcons.chat_bubble_text, size: 18, color: Color(0xFF7C7C7C)),
                      const SizedBox(width: 4),
                      Text('${post.commentCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      const Spacer(),
                      Text(_timeAgo(post.createdAt), style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.content ?? '작성된 본문이 없습니다.',
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 16),
            Text('댓글', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 300, // Fixed height for comments section
            ),
            ],
          ),
        ),
      ),

    );
  }
}
