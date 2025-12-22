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
import 'package:boulderside_flutter/src/features/login/domain/value_objects/oauth_signup_payload.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/login.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/signup_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/application/project_store.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/project_model.dart';
import 'package:boulderside_flutter/src/features/mypage/data/models/completion_response.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/blocked_users_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/completed_routes_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/completion_detail_page.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_comments_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_instagrams_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_likes_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_posts_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/my_routes_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/project_form_page.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/project_detail_page.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/route_completion_page.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/profile_edit_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/settings_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/notice_list_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/notice_detail_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/report_create_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/report_history_screen.dart';
import 'package:boulderside_flutter/src/features/mypage/presentation/screens/withdrawal_screen.dart';
import 'package:boulderside_flutter/src/features/search/presentation/screens/search_page.dart';
import 'package:boulderside_flutter/src/shared/navigation/gallery_route_data.dart';
import 'package:boulderside_flutter/src/shared/widgets/fullscreen_image_gallery.dart';
import 'package:flutter/material.dart';
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
        path: AppRoutes.signup,
        builder: (context, state) {
          final payload = _extraOrNull<OAuthSignupPayload>(state);
          return SignupScreen(signupPayload: payload);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainPage(),
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
          final extra = state.extra;
          if (extra is CompanionDetailArguments) {
            return CompanionDetailPage(
              post: extra.post,
              scrollToCommentId: extra.scrollToCommentId,
            );
          }
          final post = _extraOrNull<CompanionPost>(state);
          return CompanionDetailPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.communityBoardDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is BoardDetailArguments) {
            return BoardDetailPage(
              post: extra.post,
              scrollToCommentId: extra.scrollToCommentId,
            );
          }
          final post = _extraOrNull<BoardPost>(state);
          return BoardDetailPage(post: post);
        },
      ),
      GoRoute(
        path: AppRoutes.boulderDetail,
        builder: (context, state) {
          final boulder = _extraOrNull<BoulderModel>(state);
          return boulder != null
              ? BoulderDetail(boulder: boulder)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.routeDetail,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is RouteDetailArguments) {
            return RouteDetailPage(
              route: extra.route,
              scrollToCommentId: extra.scrollToCommentId,
            );
          }
          final route = _extraOrNull<RouteModel>(state);
          return route != null
              ? RouteDetailPage(route: route)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.gallery,
        builder: (context, state) {
          final args = _extraOrNull<GalleryRouteData>(state);
          return args != null
              ? FullScreenImageGallery(
                  imageUrls: args.imageUrls,
                  initialIndex: args.initialIndex,
                )
              : const _InvalidRouteScreen();
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
        builder: (context, state) {
          final extra = state.extra;
          final filter = extra is ProjectFilter ? extra : ProjectFilter.all;
          return MyRoutesScreen(initialFilter: filter);
        },
      ),
      GoRoute(
        path: AppRoutes.completedRoutes,
        builder: (context, state) => const CompletedRoutesScreen(),
      ),
      GoRoute(
        path: AppRoutes.completionDetail,
        builder: (context, state) {
          final completion = _extraOrNull<CompletionResponse>(state);
          return completion != null
              ? CompletionDetailPage(completion: completion)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (context, state) {
          final project = _extraOrNull<ProjectModel>(state);
          return project != null
              ? ProjectDetailPage(project: project)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.projectForm,
        builder: (context, state) {
          final args = _extraOrNull<ProjectFormArguments>(state);
          return args != null
              ? ProjectFormPage(args: args)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.routeCompletion,
        builder: (context, state) {
          final args = _extraOrNull<RouteCompletionPageArgs>(state);
          return args != null
              ? RouteCompletionPage(args: args)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.myComments,
        builder: (context, state) => const MyCommentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.myInstagrams,
        builder: (context, state) => const MyInstagramsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.blockedUsers,
        builder: (context, state) => const BlockedUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.withdrawal,
        builder: (context, state) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: AppRoutes.noticeList,
        builder: (context, state) => const NoticeListScreen(),
      ),
      GoRoute(
        path: AppRoutes.noticeDetail,
        builder: (context, state) {
          final args = _extraOrNull<NoticeDetailArgs>(state);
          return args != null
              ? NoticeDetailScreen(args: args)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.reportCreate,
        builder: (context, state) {
          final args = _extraOrNull<ReportCreateArgs>(state);
          return args != null
              ? ReportCreateScreen(args: args)
              : const _InvalidRouteScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.reportHistory,
        builder: (context, state) => const ReportHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),
    ],
  );
}

T? _extraOrNull<T>(GoRouterState state) {
  final extra = state.extra;
  if (extra is T) {
    return extra;
  }
  return null;
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            const Text(
              '잘못된 경로입니다.\n다시 시도해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('홈으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
