import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/board_create.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/board_detail.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/community.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/companion_create.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/companion_detail.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/email_login_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/find_id_result_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/login.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/phone_verification_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/reset_password_screen.dart';
import 'package:boulderside_flutter/main.dart';
import 'package:boulderside_flutter/src/features/search/presentation/screens/search_page.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/screens/signup_form.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/screens/signup_phone_verification.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String emailLogin = '/email-login';
  static const String phoneVerification = '/phone-verification';
  static const String findIdResult = '/find-id-result';
  static const String resetPassword = '/reset-password';
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

      case phoneVerification:
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments;
            final purpose =
                args is VerificationPurpose ? args : VerificationPurpose.findId;
            return PhoneVerificationScreen(
              purpose: purpose,
            );
          },
          settings: settings,
        );

      case findIdResult:
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments;
            String phoneNumber = '';
            String? email;
            if (args is Map<String, dynamic>) {
              final phoneArg = args['phoneNumber'];
              if (phoneArg is String) {
                phoneNumber = phoneArg;
              }
              final emailArg = args['email'];
              if (emailArg is String) {
                email = emailArg;
              }
            }
            return FindIdResultScreen(
              phoneNumber: phoneNumber,
              email: email,
            );
          },
          settings: settings,
        );

      case resetPassword:
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments;
            String phoneNumber = '';
            String? email;
            if (args is Map<String, dynamic>) {
              final phoneArg = args['phoneNumber'];
              if (phoneArg is String) {
                phoneNumber = phoneArg;
              }
              final emailArg = args['email'];
              if (emailArg is String) {
                email = emailArg;
              }
            }
            return ResetPasswordScreen(
              phoneNumber: phoneNumber,
              email: email,
            );
          },
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
            final args = settings.arguments;
            final phoneNumber = args is String ? args : '';
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
            final args = settings.arguments;
            final post = args is CompanionPost ? args : null;
            return CompanionDetailPage(post: post);
          },
          settings: settings,
        );

      case communityBoardDetail:
        return MaterialPageRoute(
          builder: (context) {
            final args = settings.arguments;
            final post = args is BoardPost ? args : null;
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
