import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const SortButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        backgroundColor: selected ? Colors.white : Colors.black,
        foregroundColor: selected ? Colors.black : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0,
        ),
      ),
    );
  }
}
