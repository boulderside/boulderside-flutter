import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

typedef BoardPostCallback = void Function(BoardPostResponse post);

class BoardPostFormPage extends StatefulWidget {
  const BoardPostFormPage({super.key, this.post, this.onSuccess});

  final BoardPostResponse? post;
  final BoardPostCallback? onSuccess;

  @override
  State<BoardPostFormPage> createState() => _BoardPostFormPageState();
}

class _BoardPostFormPageState extends State<BoardPostFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late final BoardPostService _service;

  bool _isLoading = false;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _service = context.read<BoardPostService>();
    if (_isEditing) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      late BoardPostResponse response;

      if (_isEditing) {
        final request = UpdateBoardPostRequest(title: title, content: content);
        response = await _service.updatePost(widget.post!.boardPostId, request);
      } else {
        final request = CreateBoardPostRequest(title: title, content: content);
        response = await _service.createPost(request);
      }

      if (!mounted) return;
      widget.onSuccess?.call(response);
      _showSuccessSnackBar();
      context.pop<BoardPostResponse>(response);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게시글 ${_isEditing ? '수정' : '생성'}에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
        title: Text(
          _isEditing ? '게시판 글 수정' : '게시판 글쓰기',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                _LabeledField(
                  label: '제목',
                  child: TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('제목을 입력하세요'),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: '내용',
                  child: TextField(
                    controller: _contentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('내용을 입력하세요'),
                    maxLines: 8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isLoading ? null : _submitPost,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(_isEditing ? '수정 완료' : '글 생성'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0B3B8)),
      filled: true,
      fillColor: const Color(0xFF262A34),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A3F4B)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF3A3F4B)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF3278)),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? '게시글이 수정되었습니다.' : '게시글이 생성되었습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
