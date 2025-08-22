import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/board_post.dart';
import '../models/comment.dart';
import '../widgets/comment_list.dart';
import '../widgets/comment_input.dart';

class BoardDetailPage extends StatefulWidget {
  final BoardPost? post;
  const BoardDetailPage({super.key, this.post});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = [
      CommentModel(authorNickname: 'stonecat', content: '정성스러운 글 감사합니다!', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
    ];
  }

  void _addComment(String text) {
    setState(() {
      _comments = List.of(_comments)
        ..add(CommentModel(authorNickname: 'me', content: text, createdAt: DateTime.now()));
    });
  }

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
    final post = widget.post ?? BoardPost(
      title: '게시판 상세',
      authorNickname: 'guest',
      commentCount: 0,
      viewCount: 0,
      createdAt: DateTime.now(),
      content: '게시판 글 내용이 없습니다.',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('게시판 글', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: ListView(
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
          Text('댓글 ${_comments.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          CommentList(comments: _comments),
          const SizedBox(height: 60),
        ],
      ),
      bottomNavigationBar: AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: CommentInput(onSubmit: _addComment),
      ),
    );
  }
}
