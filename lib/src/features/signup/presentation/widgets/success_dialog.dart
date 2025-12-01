import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final bool isExistingUser;

  const SuccessDialog({super.key, required this.isExistingUser});

  static void show(BuildContext context, bool isExistingUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SuccessDialog(isExistingUser: isExistingUser);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF181A20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 28),
          const SizedBox(width: 12),
          Text(
            isExistingUser ? '계정 연동 완료' : '회원가입 완료',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        isExistingUser
            ? '계정이 성공적으로 연동되었습니다.\n로그인하여 서비스를 이용해보세요.'
            : '회원가입이 완료되었습니다.\n로그인하여 서비스를 이용해보세요.',
        style: const TextStyle(
          fontFamily: 'Pretendard',
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/', // 로그인 화면으로 이동
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3278),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
