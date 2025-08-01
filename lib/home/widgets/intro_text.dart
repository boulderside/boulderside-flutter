import 'package:flutter/material.dart';

class BoulderIntroText extends StatelessWidget {
  const BoulderIntroText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
          child: Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Text(
              '오늘은 자연볼더링을 해볼까요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 10),
          child: Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Text(
              'Boulderside에서 바위를 탐색해봐요!',
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Color(0xFF7C7C7C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
