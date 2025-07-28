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
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment(0, 0),
                      child: TabBar(
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white,
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          letterSpacing: 0.0,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          letterSpacing: 0.0,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        indicatorColor: Color(0xFFFF3278),
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(text: '바위'),
                          Tab(text: '루트'),
                        ],
                        controller: _tabController,
                        onTap: (i) async {
                          [() async {}, () async {}][i]();
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Column(mainAxisSize: MainAxisSize.max, children: []),
                          Column(mainAxisSize: MainAxisSize.max, children: []),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(-1, 0),
                        child: Text(
                          '오늘은 자연볼더링을 해볼까요?',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    child: Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(),
                      child: Text(
                        'Boulderside에서 바위를 탐색해봐요!',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color(0xFF7C7C7C),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
