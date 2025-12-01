import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpandableSection extends StatelessWidget {
  final String title; // 헤더 제목
  final bool expanded; // 현재 펼쳐진 상태
  final VoidCallback onToggle; // 토글 이벤트
  final Widget child; // 펼쳐졌을 때 보여줄 위젯

  const ExpandableSection({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // 헤더
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF262A34),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(8),
              bottom: expanded ? Radius.zero : const Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  expanded
                      ? CupertinoIcons.chevron_down
                      : CupertinoIcons.chevron_forward,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),

        // 펼친 상태일 때 child 보이기
        if (expanded)
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF262A34),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: child,
          ),

        const SizedBox(height: 10), // 간격
      ],
    );
  }
}
