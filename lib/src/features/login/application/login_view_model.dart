import 'package:boulderside_flutter/src/features/login/application/kakao_login_client.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
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
  const LoginEvent._(this.type, {this.message});

  factory LoginEvent.showMessage(String message) =>
      LoginEvent._(LoginEventType.showMessage, message: message);

  factory LoginEvent.navigateToHome({String? message}) =>
      LoginEvent._(LoginEventType.navigateHome, message: message);

  factory LoginEvent.navigateToSignup() =>
      const LoginEvent._(LoginEventType.navigateSignup);

  final LoginEventType type;
  final String? message;
}

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(this._kakaoLoginClient, this._authRepository)
    : super(const LoginState());

  final KakaoLoginClient _kakaoLoginClient;
  final AuthRepository _authRepository;

  static const Map<String, String> _providerNames = {
    'naver': '네이버',
    'kakao': '카카오',
    'apple': '애플',
    'google': '구글',
  };

  Future<void> login(String provider) async {
    if (state.loadingProvider != null) return;

    if (provider == 'kakao') {
      await _loginWithKakao();
      return;
    }

    final providerName = _providerNames[provider];
    final message = providerName == null
        ? '지원하지 않는 로그인 방식입니다.'
        : '$providerName 로그인은 현재 준비 중입니다. 잠시만 기다려주세요.';
    _emitEvent(LoginEvent.showMessage(message));
  }

  Future<void> _loginWithKakao() async {
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

      await _completeBackendLogin(accessToken);
    } finally {
      _setLoading(null);
    }
  }

  Future<void> _completeBackendLogin(String accessToken) async {
    try {
      final loginResult = await _authRepository.loginWithKakao(
        identityToken: accessToken,
      );

      if (loginResult.isNew) {
        _emitEvent(LoginEvent.navigateToSignup());
      } else {
        final nickname = loginResult.user.nickname;
        _emitEvent(
          LoginEvent.navigateToHome(message: '$nickname님, 다시 만나 반가워요!'),
        );
      }
    } catch (_) {
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
