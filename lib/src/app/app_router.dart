import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/splash_wrapper.dart';
import 'package:boulderside_flutter/src/features/boulder/presentation/screens/boulder_detail.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/board_post_models.dart';
import 'package:boulderside_flutter/src/features/community/data/models/companion_post.dart';
import 'package:boulderside_flutter/src/features/community/data/models/mate_post_models.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/board_detail.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/community.dart';
import 'package:boulderside_flutter/src/features/community/presentation/screens/companion_detail.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/board_post_form_page.dart';
import 'package:boulderside_flutter/src/features/community/presentation/widgets/companion_post_form_page.dart';
import 'package:boulderside_flutter/src/domain/entities/boulder_model.dart';
import 'package:boulderside_flutter/src/domain/entities/route_model.dart';
import 'package:boulderside_flutter/src/features/home/presentation/screens/route_detail_page.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/email_login_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/find_id_result_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/login.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/phone_verification_screen.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/reset_password_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_likes_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_posts_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart';
import 'package:boulderside_flutter/src/features/search/presentation/screens/search_page.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/screens/signup_form.dart';
import 'package:boulderside_flutter/src/features/signup/presentation/screens/signup_phone_verification.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashWrapper(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: AppRoutes.emailLogin,
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneVerification,
        builder: (context, state) {
          final purpose = state.extra is VerificationPurpose
              ? state.extra as VerificationPurpose
              : VerificationPurpose.findId;
          return PhoneVerificationScreen(purpose: purpose);
        },
      ),
      GoRoute(
        path: AppRoutes.findIdResult,
        builder: (context, state) {
          final args = state.extra as Map<String, String?>?;
          return FindIdResultScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            email: args?['email'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final args = state.extra as Map<String, String?>?;
          return ResetPasswordScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
            email: args?['email'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignupPhoneVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUpForm,
        builder: (context, state) {
          final phone = state.extra is String ? state.extra as String : '';
          return SignupFormScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.community,
        builder: (context, state) => const Community(),
      ),
      GoRoute(
        path: AppRoutes.communityCompanionCreate,
        builder: (context, state) {
          final post = state.extra as MatePostResponse?;
          return CompanionPostFormPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.communityBoardCreate,
        builder: (context, state) {
          final post = state.extra as BoardPostResponse?;
          return BoardPostFormPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.communityCompanionDetail,
        builder: (context, state) {
          final post = state.extra as CompanionPost?;
          return CompanionDetailPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.communityBoardDetail,
        builder: (context, state) {
          final post = state.extra as BoardPost?;
          return BoardDetailPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.boulderDetail,
        builder: (context, state) {
          final boulder = state.extra as BoulderModel;
          return BoulderDetail(boulder: boulder);
        },
      ),
      GoRoute(
        path: AppRoutes.routeDetail,
        builder: (context, state) {
          final route = state.extra as RouteModel;
          return RouteDetailPage(route: route);
        },
      ),
      GoRoute(
        path: AppRoutes.myLikes,
        builder: (context, state) => const MyLikesScreen(),
      ),
      GoRoute(
        path: AppRoutes.myPosts,
        builder: (context, state) => const MyPostsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myRoutes,
        builder: (context, state) => const MyRoutesScreen(),
      ),
    ],
  );
}
