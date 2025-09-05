import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/companion_post.dart';
import '../models/post_models.dart';
import '../widgets/comment_list.dart';
import '../widgets/post_form.dart';
import '../services/post_service.dart';

class CompanionDetailPage extends StatefulWidget {
  final CompanionPost? post;
  const CompanionDetailPage({super.key, this.post});

  @override
  State<CompanionDetailPage> createState() => _CompanionDetailPageState();
}

class _CompanionDetailPageState extends State<CompanionDetailPage> {
  bool _isMenuOpen = false;
  final PostService _postService = PostService();
  PostResponse? _postResponse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostDetail();
  }

  Future<void> _loadPostDetail() async {
    if (widget.post == null) return;
    
    try {
      final postDetail = await _postService.getPost(widget.post!.id);
      if (mounted) {
        setState(() {
          _postResponse = postDetail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글을 불러오는데 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatExactDateTime(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editPost() {
    if (_postResponse == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostForm(
          postType: PostType.mate,
          post: _postResponse,
          onSuccess: (updatedPost) {
            setState(() {
              _postResponse = updatedPost;
            });
          },
        ),
      ),
    );
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF262A34),
        title: const Text(
          '게시글 삭제',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
          ),
        ),
        content: const Text(
          '이 게시글을 삭제하시겠습니까?',
          style: TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white54,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              '삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && _postResponse != null) {
      try {
        await _postService.deletePost(_postResponse!.postId);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
        Navigator.of(context).pop(true); // Return true to indicate deletion
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 삭제에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reportPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고 기능은 향후 구현될 예정입니다.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: const Color(0xFF181A20),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true to trigger refresh
            },
          ),
          title: const Text('동행 글', style: TextStyle(color: Colors.white)),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF3278),
          ),
        ),
      );
    }

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

    // Use isMine from API response
    final bool isAuthor = _postResponse?.isMine ?? false;

    return PopScope(
      onPopInvoked: (didPop) async {
        // This will be called whenever the page is popped
        // We need to pass the refresh signal back to the calling page
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(true); // Return true to trigger refresh
          },
        ),
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
                  _editPost();
                  break;
                case 'delete':
                  _deletePost();
                  break;
                case 'report':
                  _reportPost();
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
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ];
              } else {
                return const [
                  PopupMenuItem(value: 'report', child: Text('신고')),
                ];
              }
            },
          ),
        ],
      ),
      body: IgnorePointer(
        ignoring: _isMenuOpen,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Post content section
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Card(
                  color: const Color(0xFF262A34),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_postResponse?.title ?? post.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.calendar, size: 18, color: Color(0xFF7C7C7C)),
                            const SizedBox(width: 6),
                            Text(
                              _postResponse?.meetingDate != null 
                                  ? '${_postResponse!.meetingDate!.year}.${_postResponse!.meetingDate!.month.toString().padLeft(2, '0')}.${_postResponse!.meetingDate!.day.toString().padLeft(2, '0')}'
                                  : post.meetingDateLabel, 
                              style: const TextStyle(color: Colors.white, fontSize: 14)
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.person_fill, size: 18, color: Color(0xFF7C7C7C)),
                            const SizedBox(width: 6),
                            Text(_postResponse?.userInfo.nickname ?? post.authorNickname, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            const SizedBox(width: 12),
                            const Icon(CupertinoIcons.eye, size: 18, color: Color(0xFF7C7C7C)),
                            const SizedBox(width: 4),
                            Text('${_postResponse?.viewCount ?? post.viewCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            const SizedBox(width: 12),
                            const Icon(CupertinoIcons.chat_bubble_text, size: 18, color: Color(0xFF7C7C7C)),
                            const SizedBox(width: 4),
                            Text('${post.commentCount}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            const Spacer(),
                            Text(_formatExactDateTime(_postResponse?.createdAt ?? post.createdAt), style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _postResponse?.content ?? post.content ?? '작성된 본문이 없습니다.',
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Comments section
              Expanded(
                child: CommentList(
                  domainType: 'posts',
                  domainId: _postResponse?.postId ?? post.id,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
