import 'package:boulderside_flutter/home/widgets/rec_boulder_list.dart';
import 'package:boulderside_flutter/home/widgets/boulder_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static String routeName = 'Home';
  static String routePath = '/home';

  @override
  State<Home> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<Home> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF181A20),
        appBar: AppBar(
          backgroundColor: Color(0xFF181A20),
          automaticallyImplyLeading: false,
          title: Text(
            '바위 / 루트',
            style: TextStyle(
              fontFamily: 'Pretendard',
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search, color: Colors.white, size: 24),
              onPressed: () {
                print('IconButton pressed ...');
              },
            ),
          ],
          centerTitle: false,
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: 'Pretendard',
              letterSpacing: 0.0,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            indicatorColor: Color(0xFFFF3278),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: '바위'),
              Tab(text: '루트'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 바위 탭
            Column(
              children: [
                RecBoulderList(),
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
                Expanded(child: BoulderList()), // ← 여기서 overflow 안 나게 함
              ],
            ),

            // 루트 탭
            Center(
              child: Text('루트 탭 콘텐츠', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
