import 'package:boulderside_flutter/src/features/login/application/kakao_login_client.dart';
import 'package:boulderside_flutter/src/features/login/application/google_login_client.dart';
import 'package:boulderside_flutter/src/features/login/domain/exceptions/user_not_registered_exception.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/auth_provider_type.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/oauth_signup_payload.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  const LoginState({this.loadingProvider, this.event});

  final String? loadingProvider;
  final LoginEvent? event;

  bool isLoading(String provider) => loadingProvider == provider;

  LoginState copyWith({
    Object? loadingProvider = _sentinel,
    bool clearEvent = false,
    LoginEvent? event,
  }) {
    return LoginState(
      loadingProvider: identical(loadingProvider, _sentinel)
          ? this.loadingProvider
          : loadingProvider as String?,
      event: clearEvent ? null : (event ?? this.event),
    );
  }
}

const _sentinel = Object();

enum LoginEventType { showMessage, navigateHome, navigateSignup }

class LoginEvent {
  const LoginEvent._(this.type, {this.message, this.payload});

  factory LoginEvent.showMessage(String message) =>
      LoginEvent._(LoginEventType.showMessage, message: message);

  factory LoginEvent.navigateToHome({String? message}) =>
      LoginEvent._(LoginEventType.navigateHome, message: message);

  factory LoginEvent.navigateToSignup({required OAuthSignupPayload payload}) =>
      LoginEvent._(LoginEventType.navigateSignup, payload: payload);

  final LoginEventType type;
  final String? message;
  final OAuthSignupPayload? payload;
}

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(
    this._kakaoLoginClient,
    this._googleLoginClient,
    this._authRepository,
  ) : super(const LoginState());

  final KakaoLoginClient _kakaoLoginClient;
  final GoogleLoginClient _googleLoginClient;
  final AuthRepository _authRepository;

  static const Map<String, AuthProviderType> _providerTypes = {
    'kakao': AuthProviderType.kakao,
    'google': AuthProviderType.google,
  };

  Future<void> login(String provider) async {
    if (state.loadingProvider != null) return;

    final providerType = _providerTypes[provider];
    if (providerType == null) {
      _emitEvent(LoginEvent.showMessage('지원하지 않는 로그인 방식입니다.'));
      return;
    }

    if (providerType == AuthProviderType.kakao) {
      await _loginWithKakao(providerType);
      return;
    }

    if (providerType == AuthProviderType.google) {
      await _loginWithGoogle(providerType);
      return;
    }

    _emitEvent(LoginEvent.showMessage('현재는 카카오와 구글 로그인을 지원하고 있어요.'));
  }

  Future<void> _loginWithKakao(AuthProviderType providerType) async {
    _setLoading('kakao');
    try {
      final result = await _kakaoLoginClient.login();

      if (result.isCancelled) {
        _emitEvent(LoginEvent.showMessage('카카오 로그인을 취소했어요.'));
        return;
      }

      if (!result.isSuccess) {
        _emitEvent(
          LoginEvent.showMessage(
            result.errorMessage ?? '카카오 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.',
          ),
        );
        return;
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        _emitEvent(LoginEvent.showMessage('카카오 인증 토큰을 확인할 수 없습니다.'));
        return;
      }

      await _completeBackendLogin(accessToken, providerType: providerType);
    } finally {
      _setLoading(null);
    }
  }

  Future<void> _loginWithGoogle(AuthProviderType providerType) async {
    _setLoading('google');
    try {
      final result = await _googleLoginClient.login();

      if (result.isCancelled) {
        _emitEvent(LoginEvent.showMessage('구글 로그인을 취소했어요.'));
        return;
      }

      if (!result.isSuccess) {
        _emitEvent(
          LoginEvent.showMessage(
            result.errorMessage ?? '구글 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.',
          ),
        );
        return;
      }

      final token = result.idToken ?? result.accessToken;

      if (token == null) {
        _emitEvent(LoginEvent.showMessage('구글 인증 토큰을 확인할 수 없습니다.'));
        return;
      }

      await _completeBackendLogin(token, providerType: providerType);
    } finally {
      _setLoading(null);
    }
  }

  Future<void> _completeBackendLogin(
    String accessToken, {
    required AuthProviderType providerType,
  }) async {
    try {
      final loginResult = await _authRepository.loginWithOAuth(
        providerType: providerType,
        identityToken: accessToken,
      );

      if (loginResult.isNew) {
        _emitEvent(
          LoginEvent.navigateToSignup(
            payload: OAuthSignupPayload(
              providerType: providerType,
              identityToken: accessToken,
            ),
          ),
        );
      } else {
        final nickname = loginResult.user.nickname;
        _emitEvent(
          LoginEvent.navigateToHome(message: '$nickname님, 다시 만나 반가워요!'),
        );
      }
    } on UserNotRegisteredException {
      _emitEvent(
        LoginEvent.navigateToSignup(
          payload: OAuthSignupPayload(
            providerType: providerType,
            identityToken: accessToken,
          ),
        ),
      );
    } catch (error) {
      _emitEvent(LoginEvent.showMessage('서버 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.'));
    }
  }

  void _emitEvent(LoginEvent event) {
    state = state.copyWith(event: event);
  }

  void _setLoading(String? provider) {
    state = state.copyWith(
      loadingProvider: provider,
      clearEvent: provider != null,
    );
  }

  void clearEvent() {
    if (state.event != null) {
      state = state.copyWith(clearEvent: true);
    }
  }
}
