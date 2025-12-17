import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/mypage/application/withdrawal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  bool _isChecked = false;
  final TextEditingController _confirmationTextController =
      TextEditingController();
  final TextEditingController _reasonTextController = TextEditingController();
  static const String _confirmationText = '탈퇴합니다';

  String? _selectedReason;
  static const List<String> _reasons = [
    '앱이 너무 무거워요',
    '기능이 부족해요',
    '잘 안 쓰게 돼요',
    '기타 (직접 입력)',
  ];

  @override
  void dispose() {
    _confirmationTextController.dispose();
    _reasonTextController.dispose();
    super.dispose();
  }

  void _confirmWithdrawal() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262A34),
          title: const Text(
            '회원탈퇴',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white),
          ),
          content: const Text(
            '정말 탈퇴하시겠습니까?',
            style: TextStyle(fontFamily: 'Pretendard', color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text(
                '취소',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                dialogContext.pop();
                String? reason;
                if (_selectedReason == '기타 (직접 입력)') {
                  reason = _reasonTextController.text.trim();
                  if (reason.isEmpty) {
                    reason = null;
                  }
                } else {
                  reason = _selectedReason;
                }
                await ref
                    .read(withdrawalViewModelProvider.notifier)
                    .withdraw(reason);
              },
              child: const Text(
                '탈퇴',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: Color(0xFFFF3278),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(withdrawalViewModelProvider);

    final bool requiresCustomReason = _selectedReason == '기타 (직접 입력)';
    final bool isCustomReasonValid =
        !requiresCustomReason || _reasonTextController.text.trim().isNotEmpty;

    final isButtonEnabled =
        _isChecked &&
        _confirmationTextController.text == _confirmationText &&
        isCustomReasonValid &&
        !state.isLoading;

    ref.listen(withdrawalViewModelProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 처리 중 오류가 발생했습니다: ${next.error}')),
        );
      } else if (!next.isLoading &&
          !next.hasError &&
          next.hasValue &&
          previous?.isLoading == true) {
        // Success
        context.go(AppRoutes.login);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원탈퇴가 완료되었습니다.')));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A20),
        foregroundColor: Colors.white,
        title: const Text(
          '회원탈퇴',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '탈퇴하시면 모든 활동 내역이 삭제되며\n복구할 수 없습니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF262A34),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '⚠️ 참고사항 (필수 고지)',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: Color(0xFFFF3278),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  _WarningText(
                    title: '법령에 의한 보관',
                    content: '관계 법령에 따라 결제 내역(5년), 접속 로그(3개월) 등은 별도 보관됩니다.',
                  ),
                  SizedBox(height: 12),
                  _WarningText(
                    title: '재가입 제한',
                    content:
                        '부정 이용 방지를 위해 탈퇴 후 30일간 재가입이 불가능하며, 이를 확인하기 위한 최소한의 정보가 암호화되어 보관됩니다.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Withdrawal Survey
            const Text(
              '떠나시는 이유를 알려주시면\n서비스 개선에 큰 도움이 됩니다. (선택)',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ..._reasons.map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  _selectedReason == reason
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: _selectedReason == reason
                      ? const Color(0xFFFF3278)
                      : Colors.white54,
                ),
                title: Text(
                  reason,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedReason = reason;
                  });
                },
              ),
            ),
            if (_selectedReason == '기타 (직접 입력)')
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: TextField(
                  controller: _reasonTextController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '사유를 입력해주세요',
                    hintStyle: TextStyle(color: Colors.white.withAlpha(76)),
                    filled: true,
                    fillColor: const Color(0xFF262A34),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Confirmation Checkbox
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  activeColor: const Color(0xFFFF3278),
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.grey[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  '위 내용을 모두 확인했습니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _confirmationTextController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '"$_confirmationText"를 입력해주세요',
                hintStyle: TextStyle(color: Colors.white.withAlpha(76)),
                filled: true,
                fillColor: const Color(0xFF262A34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? _confirmWithdrawal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3278),
                  disabledBackgroundColor: Colors.grey[800],
                  disabledForegroundColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '탈퇴하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
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

class _WarningText extends StatelessWidget {
  const _WarningText({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
