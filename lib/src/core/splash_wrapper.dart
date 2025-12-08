import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/routes/app_routes.dart';
import 'package:boulderside_flutter/src/core/user/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SplashWrapper extends ConsumerStatefulWidget {
  const SplashWrapper({super.key});

  @override
  ConsumerState<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends ConsumerState<SplashWrapper> {
  late final Future<bool> _initFuture;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkLoginAndHydrate();
  }

  // SecureStorage의 accessToken과 SharedPreferences의 auto_login flag 모두 확인
  Future<bool> _checkLoginAndHydrate() async {
    final userStore = ref.read(userStoreProvider.notifier);
    final tokenStore = GetIt.I<TokenStore>();
    try {
      // 1. SecureStorage에서 accessToken 확인
      final accessToken = await tokenStore.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        await userStore.clearUser();
        return false;
      }

      // 2. SharedPreferences에서 auto_login flag 확인
      final autoLogin = await tokenStore.getAutoLogin();
      if (!autoLogin) {
        await userStore.clearUser();
        return false;
      }

      await userStore.initializeUser();
      return true;
    } catch (e) {
      // 에러 발생 시 로그인 안된 것으로 처리하고 사용자 정보 초기화
      await userStore.clearUser();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final target = snapshot.data == true
                ? AppRoutes.home
                : AppRoutes.login;
            context.go(target);
          });
        }

        return const SizedBox.shrink();
      },
    );
  }
}
