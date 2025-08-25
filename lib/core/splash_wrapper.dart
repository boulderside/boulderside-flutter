import 'package:boulderside_flutter/login/screens/login.dart';
import 'package:boulderside_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
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
