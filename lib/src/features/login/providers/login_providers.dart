import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/login/application/apple_login_client.dart';
import 'package:boulderside_flutter/src/features/login/application/google_login_client.dart';
import 'package:boulderside_flutter/src/features/login/application/kakao_login_client.dart';
import 'package:boulderside_flutter/src/features/login/application/login_view_model.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return di<AuthRepository>();
});

final kakaoLoginClientProvider = Provider<KakaoLoginClient>((ref) {
  return KakaoLoginClientImpl();
});

final googleLoginClientProvider = Provider<GoogleLoginClient>((ref) {
  return GoogleLoginClientImpl();
});

final appleLoginClientProvider = Provider<AppleLoginClient>((ref) {
  return AppleLoginClientImpl();
});

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      return LoginViewModel(
        ref.watch(kakaoLoginClientProvider),
        ref.watch(googleLoginClientProvider),
        ref.watch(appleLoginClientProvider),
        ref.watch(authRepositoryProvider),
      );
    });
