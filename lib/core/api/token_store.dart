import '../SecureStorage.dart';

class TokenStore {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static final SecureStorage _secureStorage = SecureStorage();

  // Access Token 관리
  static Future<void> setAccessToken(String token) async {
    await _secureStorage.write(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(_accessTokenKey);
  }

  // Refresh Token 관리
  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(_refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(_refreshTokenKey);
  }

  // 토큰 저장 (로그인 성공 시)
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
    ]);
  }

  // 토큰 삭제 (로그아웃 시)
  static Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(_accessTokenKey),
      _secureStorage.delete(_refreshTokenKey),
    ]);
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
