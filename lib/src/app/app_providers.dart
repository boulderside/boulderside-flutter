import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/api/api_client.dart';
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
        Provider<RouteService>(create: (_) => RouteService(ApiClient.dio)),

        /// Community feature services
        Provider<MatePostService>(create: (_) => MatePostService()),
        Provider<BoardPostService>(create: (_) => BoardPostService()),
        Provider<CommentService>(create: (_) => CommentService()),

        /// Login/signup/search services
        Provider<ChangePasswordService>(create: (_) => ChangePasswordService()),
        Provider<PhoneOtpService>(create: (_) => PhoneOtpService()),
        Provider<SignupFormService>(create: (_) => SignupFormService()),
        Provider<SearchService>(create: (_) => SearchService()),
      ],
      child: child,
    );
  }
}
