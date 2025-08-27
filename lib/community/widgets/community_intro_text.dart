import 'package:flutter/material.dart';

class CommunityIntroText extends StatelessWidget {
  const CommunityIntroText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
          child: Align(
            alignment: AlignmentDirectional(-1, 0),
            child: Text(
              '클라이머들과 소통해봐요!',
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
              'Boulderside에서 동행을 구하고 정보를 공유해봐요!',
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