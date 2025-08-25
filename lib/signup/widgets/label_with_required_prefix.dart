import 'package:flutter/material.dart';

class LabelWithRequiredPrefix extends StatelessWidget {
  final String label;

  const LabelWithRequiredPrefix({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    const prefix = '[필수] ';
    if (label.startsWith(prefix)) {
      final rest = label.substring(prefix.length);
      return RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: prefix,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFFFF3278),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: rest,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
