import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:boulderside_flutter/src/features/login/data/services/change_password_service.dart';
import 'package:boulderside_flutter/src/features/auth/data/services/phone_otp_service.dart';
import 'package:boulderside_flutter/src/features/search/data/services/search_service.dart';
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
        ChangeNotifierProvider<UserStore>.value(value: di<UserStore>()),

        /// Shared route service (others still depend on Provider)
        Provider<RouteService>.value(value: di<RouteService>()),

        /// Community feature services
        Provider<MatePostService>.value(value: di<MatePostService>()),
        Provider<BoardPostService>.value(value: di<BoardPostService>()),
        Provider<CommentService>.value(value: di<CommentService>()),

        /// Login/signup/search services
        Provider<ChangePasswordService>.value(
          value: di<ChangePasswordService>(),
        ),
        Provider<PhoneOtpService>.value(value: di<PhoneOtpService>()),
        Provider<SignupFormService>.value(value: di<SignupFormService>()),
        Provider<SearchService>.value(value: di<SearchService>()),
      ],
      child: child,
    );
  }
}
