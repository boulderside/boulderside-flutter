import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AppleLoginClient {
  Future<AppleLoginResult> login();
}

class AppleLoginClientImpl implements AppleLoginClient {
  @override
  Future<AppleLoginResult> login() async {
    try {
      final webAuthenticationOptions = _webAuthenticationOptionsOrNull();
      if (_requiresWebAuth && webAuthenticationOptions == null) {
        return AppleLoginResult.failure('애플 로그인 설정값이 누락되었습니다.');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: webAuthenticationOptions,
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        return AppleLoginResult.failure('Apple ID 토큰을 가져올 수 없습니다.');
      }

      return AppleLoginResult.success(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        userId: credential.userIdentifier,
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return AppleLoginResult.cancelled();
      }
      return AppleLoginResult.failure('애플 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.');
    } on SignInWithAppleNotSupportedException {
      return AppleLoginResult.failure('이 기기에서는 애플 로그인을 지원하지 않습니다.');
    } catch (error) {
      return AppleLoginResult.failure(error.toString());
    }
  }

  bool get _requiresWebAuth =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  WebAuthenticationOptions? _webAuthenticationOptionsOrNull() {
    if (!_requiresWebAuth) {
      return null;
    }

    const clientId = String.fromEnvironment('APPLE_CLIENT_ID');
    const redirectUri = String.fromEnvironment('APPLE_REDIRECT_URI');
    if (clientId.isEmpty || redirectUri.isEmpty) {
      return null;
    }

    return WebAuthenticationOptions(
      clientId: clientId,
      redirectUri: Uri.parse(redirectUri),
    );
  }
}

class AppleLoginResult {
  const AppleLoginResult._({
    this.identityToken,
    this.authorizationCode,
    this.userId,
    this.email,
    this.givenName,
    this.familyName,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory AppleLoginResult.success({
    required String identityToken,
    String? authorizationCode,
    String? userId,
    String? email,
    String? givenName,
    String? familyName,
  }) {
    return AppleLoginResult._(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
      userId: userId,
      email: email,
      givenName: givenName,
      familyName: familyName,
    );
  }

  factory AppleLoginResult.failure(String message) {
    return AppleLoginResult._(errorMessage: message);
  }

  factory AppleLoginResult.cancelled() {
    return const AppleLoginResult._(isCancelled: true);
  }

  final String? identityToken;
  final String? authorizationCode;
  final String? userId;
  final String? email;
  final String? givenName;
  final String? familyName;
  final String? errorMessage;
  final bool isCancelled;

  bool get isSuccess =>
      identityToken != null && errorMessage == null && !isCancelled;
}
