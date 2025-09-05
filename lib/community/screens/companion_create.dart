import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../models/post_models.dart';

class CompanionCreatePage extends StatefulWidget {
  const CompanionCreatePage({super.key});

  static const routePath = '/community/companion/create';

  @override
  State<CompanionCreatePage> createState() => _CompanionCreatePageState();
}

class _CompanionCreatePageState extends State<CompanionCreatePage> {
  int stepIndex = 0; // 0: date, 1: form
  DateTime? selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final PostService _postService = PostService();
  bool _isLoading = false;

  

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void goNext() {
    if (stepIndex == 0 && selectedDate == null) return;
    if (stepIndex < 1) {
      setState(() => stepIndex += 1);
    }
  }

  Future<void> createPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreatePostRequest(
        title: title,
        content: content,
        postType: PostType.mate,
        meetingDate: selectedDate,
      );

      await _postService.createPost(request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('동행 게시글이 생성되었습니다: $title'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('게시글 생성에 실패했습니다: $e'),
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
          onPressed: () {
            if (stepIndex > 0) {
              setState(() => stepIndex -= 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        title: Text(
          stepIndex == 0
              ? '동행 글쓰기 (1/2)'
              : '동행 글쓰기 (2/2)',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (stepIndex) {
            0 => _buildCalendarSelect(),
            _ => _buildForm(),
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (stepIndex > 0)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3A3F4B)),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => setState(() => stepIndex -= 1),
                  child: const Text('이전'),
                ),
              ),
            if (stepIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : (stepIndex == 1 ? createPost : goNext),
                child: _isLoading && stepIndex == 1
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(stepIndex == 1 ? '글 생성' : '다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildCalendarSelect() {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '만날 날짜를 선택해주세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Card(
              color: const Color(0xFF262A34),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    // Ensure calendar text/icons contrast on dark background
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      surface: const Color(0xFF262A34),
                      onSurface: Colors.white,
                      primary: const Color(0xFFFF3278),
                      onPrimary: Colors.white,
                    ),
                    textTheme: Theme.of(context).textTheme.apply(
                          bodyColor: Colors.white,
                          displayColor: Colors.white,
                        ),
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  child: CalendarDatePicker(
                    initialDate: selectedDate ?? firstDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateChanged: (date) => setState(() => selectedDate = date),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _LabeledField(
          label: '제목',
          child: TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('제목을 입력하세요'),
          ),
        ),
        const SizedBox(height: 16),
        _LabeledField(
          label: '내용',
          child: TextField(
            controller: contentController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('내용을 입력하세요'),
            maxLines: 8,
          ),
        ),
        const SizedBox(height: 8),
        if (selectedDate != null)
          Text(
            '만날 날짜: ${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Color(0xFFB0B3B8), fontSize: 13),
          ),
      ],
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
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

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
