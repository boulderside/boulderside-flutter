import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RockItem {
  final String name;
  final String region;
  const RockItem({required this.name, required this.region});
}

class CompanionCreatePage extends StatefulWidget {
  const CompanionCreatePage({super.key});

  static const routePath = '/community/companion/create';

  @override
  State<CompanionCreatePage> createState() => _CompanionCreatePageState();
}

class _CompanionCreatePageState extends State<CompanionCreatePage> {
  int stepIndex = 0; // 0: rock select, 1: date, 2: form

  RockItem? selectedRock;
  DateTime? selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final List<RockItem> demoRocks = const [
    RockItem(name: '남양주 바위 A', region: '경기도 남양주시'),
    RockItem(name: '도봉산 크랙 B', region: '서울 도봉구'),
    RockItem(name: '인수봉 루트 C', region: '서울 종로구'),
    RockItem(name: '청계산 슬랩 D', region: '경기 과천시'),
  ];

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void goNext() {
    if (stepIndex == 0 && selectedRock == null) return;
    if (stepIndex == 1 && selectedDate == null) return;
    if (stepIndex < 2) {
      setState(() => stepIndex += 1);
    }
  }

  void createPost() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty || selectedRock == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요.')),
      );
      return;
    }

    // TODO: Integrate with backend to create a companion post
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('동행 게시글이 생성되었습니다: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
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
              ? '동행 글쓰기 - 장소 선택'
              : stepIndex == 1
                  ? '동행 글쓰기 - 날짜 선택'
                  : '동행 글쓰기 - 내용 작성',
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
            0 => _buildRockSelect(),
            1 => _buildCalendarSelect(),
            _ => _buildForm(),
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Builder(
          builder: (context) {
            final bool showPrev = stepIndex > 0;
            final bool isNext = stepIndex < 2; // steps 0,1

            final Widget nextButtonCore = ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: goNext,
              child: const Text('다음'),
            );

            final Widget createButton = ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3278),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: createPost,
              child: const Text('글 생성'),
            );

            return Row(
              children: [
                if (showPrev)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3A3F4B)),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () => setState(() => stepIndex -= 1),
                      child: const Text('이전'),
                    ),
                  ),
                if (showPrev) const SizedBox(width: 12),

                // NEXT button (75% width and 15px higher) or CREATE button (full width in row slot)
                if (isNext)
                  if (showPrev)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: nextButtonCore,
                      ),
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.75,
                            child: nextButtonCore,
                          ),
                        ),
                      ),
                    )
                else
                  Expanded(child: createButton),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRockSelect() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: demoRocks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final rock = demoRocks[index];
        final isSelected = selectedRock == rock;
        return GestureDetector(
          onTap: () => setState(() => selectedRock = rock),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262A34),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? const Color(0xFFFF3278) : const Color(0xFF262A34), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rock.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid, color: Color(0xFF7C7C7C), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          rock.region,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                  color: isSelected ? const Color(0xFFFF3278) : const Color(0xFF7C7C7C),
                ),
              ],
            ),
          ),
        );
      },
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
                child: CalendarDatePicker(
                  initialDate: selectedDate ?? firstDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (date) => setState(() => selectedDate = date),
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
        if (selectedRock != null || selectedDate != null)
          Text(
            [
              if (selectedRock != null) '만남 장소: ${selectedRock!.name} (${selectedRock!.region})',
              if (selectedDate != null)
                '만날 날짜: ${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}',
            ].join('  ·  '),
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
