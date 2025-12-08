import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/community/data/services/board_post_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/comment_service.dart';
import 'package:boulderside_flutter/src/features/community/data/services/mate_post_service.dart';
import 'package:boulderside_flutter/src/features/home/data/services/route_service.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Shared route service (others still depend on Provider)
        Provider<RouteService>.value(value: di<RouteService>()),

        /// Community feature services
        Provider<MatePostService>.value(value: di<MatePostService>()),
        Provider<BoardPostService>.value(value: di<BoardPostService>()),
        Provider<CommentService>.value(value: di<CommentService>()),
      ],
      child: child,
    );
  }
}
