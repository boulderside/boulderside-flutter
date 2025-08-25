import 'package:flutter/material.dart';
import 'package:boulderside_flutter/signup/widgets/label_with_required_prefix.dart';

class TermsRow extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onView;

  const TermsRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        children: [
          Checkbox(
            value: checked,
            onChanged: onChanged,
            shape: const CircleBorder(),
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFFFF3278);
              }
              return Colors.transparent;
            }),
            side: const BorderSide(color: Colors.white70, width: 1.5),
          ),
          Expanded(child: LabelWithRequiredPrefix(label: label)),
          TextButton(
            onPressed: onView,
            child: const Text(
              '보기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
