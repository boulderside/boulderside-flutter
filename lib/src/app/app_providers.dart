import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/like_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/rec_boulder_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_detail_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/change_password_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/login_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/phone_verification_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_likes_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/my_posts_service.dart';
import 'package:boulderside_flutter/src/features/mypage/data/services/route_completion_service.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/phone_auth_service.dart';
import 'package:boulderside_flutter/src/features/signup/data/services/signup_form_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Core stores
        ChangeNotifierProvider<UserStore>(
          create: (_) => UserStore(),
        ),

        /// Home feature services
        Provider<BoulderService>(create: (_) => BoulderService()),
        Provider<RecBoulderService>(create: (_) => RecBoulderService()),
        Provider<RouteService>(create: (_) => RouteService()),
        Provider<RouteDetailService>(create: (_) => RouteDetailService()),
        Provider<BoulderDetailService>(create: (_) => BoulderDetailService()),
        Provider<LikeService>(create: (_) => LikeService()),

        /// Community feature services
        Provider<MatePostService>(create: (_) => MatePostService()),
        Provider<BoardPostService>(create: (_) => BoardPostService()),
        Provider<CommentService>(create: (_) => CommentService()),

        /// Login/signup/search services
        Provider<LoginService>(create: (_) => LoginService()),
        Provider<ChangePasswordService>(create: (_) => ChangePasswordService()),
        Provider<PhoneVerificationService>(
          create: (_) => PhoneVerificationService(),
        ),
        Provider<SignupFormService>(create: (_) => SignupFormService()),
        Provider<PhoneAuthService>(create: (_) => PhoneAuthService()),
        Provider<SearchService>(create: (_) => SearchService()),

        /// My page services
        Provider<MyLikesService>(create: (_) => MyLikesService()),
        Provider<MyPostsService>(create: (_) => MyPostsService()),
        Provider<RouteCompletionService>(
          create: (_) => RouteCompletionService(),
        ),
      ],
      child: child,
    );
  }
}
