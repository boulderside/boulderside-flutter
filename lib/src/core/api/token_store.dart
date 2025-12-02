import 'package:boulderside_flutter/src/core/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStore {
  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
    bool autoLogin,
  );

  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<bool> getAutoLogin();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._secureStorage);

  final SecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _autoLoginKey = 'auto_login';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
    bool autoLogin,
  ) async {
    await Future.wait([
      _secureStorage.write(_accessTokenKey, accessToken),
      _secureStorage.write(_refreshTokenKey, refreshToken),
      _setAutoLogin(autoLogin),
    ]);
  }

  @override
  Future<String?> getAccessToken() {
    return _secureStorage.read(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.read(_refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await _prefs;
    await Future.wait([
      _secureStorage.delete(_accessTokenKey),
      _secureStorage.delete(_refreshTokenKey),
      prefs.setBool(_autoLoginKey, false),
    ]);
  }

  Future<void> _setAutoLogin(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_autoLoginKey, value);
  }

  @override
  Future<bool> getAutoLogin() async {
    final prefs = await _prefs;
    return prefs.getBool(_autoLoginKey) ?? false;
  }
}
