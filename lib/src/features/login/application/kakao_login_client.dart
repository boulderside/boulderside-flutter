import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract class KakaoLoginClient {
  Future<KakaoLoginResult> login();
}

class KakaoLoginClientImpl implements KakaoLoginClient {
  @override
  Future<KakaoLoginResult> login() async {
    try {
      final token = await _loginWithAvailableMethod();
      final user = await UserApi.instance.me();

      return KakaoLoginResult.success(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        userId: user.id,
        nickname: user.kakaoAccount?.profile?.nickname,
        profileImageUrl: user.kakaoAccount?.profile?.profileImageUrl,
      );
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        return KakaoLoginResult.cancelled();
      }
      return KakaoLoginResult.failure(error.message ?? '카카오 로그인에 실패했습니다.');
    } catch (error) {
      return KakaoLoginResult.failure(error.toString());
    }
  }

  Future<OAuthToken> _loginWithAvailableMethod() async {
    final isTalkInstalled = await isKakaoTalkInstalled();
    if (!isTalkInstalled) {
      return UserApi.instance.loginWithKakaoAccount();
    }

    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        rethrow;
      }
      return UserApi.instance.loginWithKakaoAccount();
    } catch (_) {
      return UserApi.instance.loginWithKakaoAccount();
    }
  }
}

class KakaoLoginResult {
  const KakaoLoginResult._({
    this.accessToken,
    this.refreshToken,
    this.nickname,
    this.userId,
    this.profileImageUrl,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory KakaoLoginResult.success({
    required String accessToken,
    String? refreshToken,
    int? userId,
    String? nickname,
    String? profileImageUrl,
  }) {
    return KakaoLoginResult._(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      nickname: nickname,
      profileImageUrl: profileImageUrl,
    );
  }

  factory KakaoLoginResult.failure(String message) {
    return KakaoLoginResult._(errorMessage: message);
  }

  factory KakaoLoginResult.cancelled() {
    return const KakaoLoginResult._(isCancelled: true);
  }

  final String? accessToken;
  final String? refreshToken;
  final String? nickname;
  final int? userId;
  final String? profileImageUrl;
  final String? errorMessage;
  final bool isCancelled;

  bool get isSuccess =>
      accessToken != null && errorMessage == null && !isCancelled;
}
