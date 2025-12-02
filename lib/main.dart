import 'package:boulderside_flutter/src/app/app_providers.dart';
import 'package:boulderside_flutter/src/app/app_router.dart';
import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/community.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/home.dart';
import 'package:boulderside_flutter/src/features/map/presentation/screens/map_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // 현재 로그인 기능이 구현되지 않았으므로
  // 백엔드에서 임시로 발급받은 JWT 토큰을 직접 넣는 방식으로 테스트
  TokenStore.setAccessToken(
    'Bearer eyJhbGciOiJIUzI1NiJ9.eyJjYXRlZ29yeSI6ImFjY2VzcyIsInVzZXJJZCI6MSwicm9sZSI6IlJPTEVfVVNFUiIsImlhdCI6MTc2NDU4MTg0OSwiZXhwIjoxNzY1NDQ1ODQ5fQ.86QN1_XZZ6ompkDL0YyuhICEGc3yf3c0dNsfXJQeD6E',
  );
  await _initializeNaverMap();
  runApp(MyApp());
}

Future<void> _initializeNaverMap() async {
  // 배포 시 --dart-define으로 NAVER_MAP_CLIENT_ID / SECRET을 주입
  const clientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  const clientSecret = String.fromEnvironment('NAVER_MAP_CLIENT_SECRET');

  if (clientId.isEmpty) {
    debugPrint('NAVER_MAP_CLIENT_ID가 설정되지 않았습니다. 지도가 초기화되지 않습니다.');
    return;
  }

  try {
    await FlutterNaverMap().init(
      clientId: clientId,
      onAuthFailed: (ex) =>
          debugPrint('네이버 지도 인증 실패: ${ex.message} (${ex.code})'),
    );
    if (clientSecret.isNotEmpty) {
      debugPrint('NAVER_MAP_CLIENT_SECRET은 FlutterNaverMap.init에서 사용되지 않습니다.');
    }
  } catch (e, st) {
    debugPrint('FlutterNaverMap 초기화 실패: $e\n$st');
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppRouter _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp.router(
        title: 'BottomNav',
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Pretendard'),
        debugShowCheckedModeBanner: false,
        routerConfig: _router.router,
      ),
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
    const MapScreen(),
    const Community(),
    const ProfileScreen(),
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
        selectedItemColor: const Color(0xFFFF3278),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.map), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_3_fill),
            label: 'Community',
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
