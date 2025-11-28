import 'package:boulderside_flutter/home/screens/boulder_list.dart';
import 'package:boulderside_flutter/home/screens/route_list.dart';
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
                Navigator.pushNamed(context, '/search');
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
            Column(children: [Expanded(child: BoulderList())]),

            // 루트 탭
            Column(children: [Expanded(child: RouteList())]),
          ],
        ),
      ),
    );
  }
}
