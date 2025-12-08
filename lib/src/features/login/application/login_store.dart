import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/error/result.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/features/login/domain/usecases/login_with_email_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginStore extends StateNotifier<LoginState> {
  LoginStore(this._loginWithEmailUseCase) : super(const LoginState());

  final LoginWithEmailUseCase _loginWithEmailUseCase;

  Future<void> login(String email, String password) async {
    if (email.isEmpty) {
      state = state.copyWith(errorMessage: '이메일을 입력해주세요.');
      return;
    }
    if (password.isEmpty) {
      state = state.copyWith(errorMessage: '비밀번호를 입력해주세요.');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      authenticatedUser: null,
    );

    final Result<User> result = await _loginWithEmailUseCase(
      email: email,
      password: password,
      autoLogin: state.isAutoLoginEnabled,
    );

    result.when(
      success: (user) {
        state = state.copyWith(
          authenticatedUser: user,
          isLoading: false,
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
    );
  }

  void toggleAutoLogin(bool value) {
    state = state.copyWith(isAutoLoginEnabled: value);
  }

  void consumeSuccess() {
    state = state.copyWith(authenticatedUser: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

const _sentinel = Object();

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isAutoLoginEnabled = true,
    this.authenticatedUser,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isAutoLoginEnabled;
  final User? authenticatedUser;

  bool get loginSucceeded => authenticatedUser != null;

  LoginState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    bool? isAutoLoginEnabled,
    Object? authenticatedUser = _sentinel,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isAutoLoginEnabled: isAutoLoginEnabled ?? this.isAutoLoginEnabled,
      authenticatedUser: identical(authenticatedUser, _sentinel)
          ? this.authenticatedUser
          : authenticatedUser as User?,
    );
  }
}

final loginStoreProvider = StateNotifierProvider<LoginStore, LoginState>((ref) {
  final useCase = di<LoginWithEmailUseCase>();
  return LoginStore(useCase);
});
