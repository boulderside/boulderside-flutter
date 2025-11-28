import 'package:boulderside_flutter/login/screens/login.dart';
import 'package:boulderside_flutter/main.dart';
import 'package:boulderside_flutter/core/api/token_store.dart';
import 'package:flutter/material.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  // SecureStorage의 accessToken과 SharedPreferences의 auto_login flag 모두 확인
  Future<bool> checkLogin() async {
    try {
      // 1. SecureStorage에서 accessToken 확인
      final accessToken = await TokenStore.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      // 2. SharedPreferences에서 auto_login flag 확인
      final autoLogin = await TokenStore.getAutoLogin();
      if (!autoLogin) {
        return false;
      }

      return true;
    } catch (e) {
      // 에러 발생 시 로그인 안된 것으로 처리
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLogin(),
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
