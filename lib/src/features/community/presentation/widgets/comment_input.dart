import 'package:flutter/material.dart';

class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  final bool isLoading;
  final String? initialText;
  final String hintText;
  final String submitText;

  const CommentInput({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialText,
    this.hintText = '댓글을 입력하세요...',
    this.submitText = '등록',
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
      _hasText = _controller.text.isNotEmpty;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSubmit(text);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF262A34),
        border: Border(top: BorderSide(color: Color(0xFF3E4349), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181A20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3E4349), width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      12,
                      16,
                      12,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  maxLength: 500,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) {
                        // 글자수 표시 숨기기
                        return null;
                      },
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 전송 버튼
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _hasText && !widget.isLoading ? _onSubmit : null,
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: _hasText && !widget.isLoading
                        ? const Color(0xFFFF3278)
                        : const Color(0xFF3E4349),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.submitText,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _hasText ? Colors.white : Colors.white54,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
