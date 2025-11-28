import 'package:boulderside_flutter/login/screens/login.dart';
import 'package:boulderside_flutter/main.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:boulderside_flutter/core/user/stores/user_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  late final Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkLoginAndHydrate();
  }

  // SecureStorage의 accessToken과 SharedPreferences의 auto_login flag 모두 확인
  Future<bool> _checkLoginAndHydrate() async {
    final userStore = context.read<UserStore>();
    try {
      // 1. SecureStorage에서 accessToken 확인
      final accessToken = await TokenStore.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        await userStore.clearUser();
        return false;
      }

      // 2. SharedPreferences에서 auto_login flag 확인
      final autoLogin = await TokenStore.getAutoLogin();
      if (!autoLogin) {
        await userStore.clearUser();
        return false;
      }

      await userStore.initializeUser();
      return true;
    } catch (e) {
      // 에러 발생 시 로그인 안된 것으로 처리하고 사용자 정보 초기화
      await userStore.clearUser();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return const MainPage(); // 로그인된 상태
        } else {
          return const Login(); // 로그인 안 된 상태
        }
      },
    );
  }
}
