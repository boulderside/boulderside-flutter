import 'package:flutter/material.dart';
import '../../login/screens/login.dart';
import '../../login/screens/email_login_screen.dart';
import '../../main.dart';
import '../../signup/screens/signup_phone_verification.dart';
import '../../signup/screens/signup_form.dart';
import '../../search/screens/search_page.dart';
import '../../community/screens/community.dart';
import '../../community/screens/companion_create.dart';
import '../../community/screens/board_create.dart';
import '../../community/screens/companion_detail.dart';
import '../../community/screens/board_detail.dart';
import '../../community/models/companion_post.dart';
import '../../community/models/board_post.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String emailLogin = '/email-login';
  static const String signUp = '/sign-up';
  static const String signUpForm = '/sign-up/form';
  static const String search = '/search';
  static const String community = '/community';
  static const String communityCompanionCreate = '/community/companion/create';
  static const String communityBoardCreate = '/community/board/create';
  static const String communityCompanionDetail = '/community/companion/detail';
  static const String communityBoardDetail = '/community/board/detail';

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

      case signUp:
        return MaterialPageRoute(
          builder: (context) => const SignupPhoneVerificationScreen(),
          settings: settings,
        );

      case signUpForm:
        return MaterialPageRoute(
          builder: (context) {
            final phoneNumber = settings.arguments is String
                ? settings.arguments as String
                : '';
            return SignupFormScreen(phoneNumber: phoneNumber);
          },
          settings: settings,
        );

      case search:
        return MaterialPageRoute(
          builder: (context) => const SearchPage(),
          settings: settings,
        );

      case community:
        return MaterialPageRoute(
          builder: (context) => const Community(),
          settings: settings,
        );

      case communityCompanionCreate:
        return MaterialPageRoute(
          builder: (context) => const CompanionCreatePage(),
          settings: settings,
        );

      case communityBoardCreate:
        return MaterialPageRoute(
          builder: (context) => const BoardCreatePage(),
          settings: settings,
        );

      case communityCompanionDetail:
        return MaterialPageRoute(
          builder: (context) {
            final post = settings.arguments as CompanionPost?;
            return CompanionDetailPage(post: post);
          },
          settings: settings,
        );

      case communityBoardDetail:
        return MaterialPageRoute(
          builder: (context) {
            final post = settings.arguments as BoardPost?;
            return BoardDetailPage(post: post);
          },
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
