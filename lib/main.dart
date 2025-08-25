import 'package:boulderside_flutter/core/splash_wrapper.dart';
import 'package:boulderside_flutter/home/screens/home.dart';
import 'package:boulderside_flutter/login/screens/email_login_screen.dart';
import 'package:boulderside_flutter/core/routes/app_routes.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  // 현재 로그인 기능이 구현되지 않았으므로
  // 백엔드에서 임시로 발급받은 JWT 토큰을 직접 넣는 방식으로 테스트
  TokenStore.setToken(''); // 여기에 임시로 발급받은 백엔드 토큰을 넣으면 됨

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BottomNav',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard',
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashWrapper(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Home(), // 기본 첫 화면
    const Center(child: Text('탭 2')),
    const Center(child: Text('탭 3')),
    const Center(child: Text('탭 4')),
    const Center(child: Text('탭 5')),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF262A34),
        currentIndex: _selectedIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false, // 선택된 라벨 숨김
        showUnselectedLabels: false, // 선택되지 않은 라벨 숨김
        selectedItemColor: Color(0xFFFF3278),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.dot_radiowaves_left_right),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_3_fill),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shopping_cart),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'MyPage',
          ),
        ],
      ),
    );
  }
}
