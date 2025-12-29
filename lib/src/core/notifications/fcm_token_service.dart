import 'dart:async';

import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmTokenService {
  FcmTokenService(this._dio, this._tokenStore);

  final Dio _dio;
  final TokenStore _tokenStore;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> syncFcmToken({String? token}) async {
    if (_isIosPushSkipped) {
      return;
    }
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    try {
      await _dio.patch('/users/me/fcm-token', data: {'fcmToken': fcmToken});
    } catch (error) {
      debugPrint('FCM 토큰 전송 실패: $error');
    }
  }

  void listenTokenRefresh() {
    if (_isIosPushSkipped) {
      return;
    }
    _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => syncFcmToken(token: token));
  }

  Future<void> disable() async {
    if (_isIosPushSkipped) {
      return;
    }
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (error) {
      debugPrint('FCM 토큰 삭제 실패: $error');
    }
  }
}

bool get _isIosPushSkipped =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
