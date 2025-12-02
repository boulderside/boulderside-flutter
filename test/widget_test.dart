import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/features/login/presentation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets(
    'Social login button shows coming-soon message instead of failing silently',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Login()));

      await tester.tap(find.text('카카오로 로그인하기'));
      await tester.pump();

      expect(
        find.text('카카오 로그인은 현재 준비 중입니다. 이메일 로그인으로 진행해주세요.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Email login button navigates to AppRoutes.emailLogin', (
    WidgetTester tester,
  ) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        home: const Login(),
        routes: {
          AppRoutes.emailLogin: (_) =>
              const Scaffold(body: Center(child: Text('Email Login'))),
        },
        navigatorObservers: [observer],
      ),
    );

    await tester.scrollUntilVisible(find.text('이메일로 시작하기'), 200);
    await tester.pumpAndSettle();

    await tester.tap(find.text('이메일로 시작하기'));
    await tester.pumpAndSettle();

    final pushedEmailLogin = observer.pushedRoutes.any(
      (route) => route.settings.name == AppRoutes.emailLogin,
    );
    expect(pushedEmailLogin, isTrue);
    expect(find.text('Email Login'), findsOneWidget);
  });
}
