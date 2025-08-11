import 'package:flutter/material.dart';
import '../../login/screens/login.dart';
import '../../login/screens/email_login_screen.dart';
import '../../main.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String emailLogin = '/email-login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => const Login(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => const MainPage(),
          settings: settings,
        );

      case emailLogin:
        return MaterialPageRoute(
          builder: (context) => const EmailLoginScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Login(),
          settings: settings,
        );
    }
  }
}
