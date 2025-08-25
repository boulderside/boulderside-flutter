class TokenStore {
  // jwt 토큰을 관리하는 파일

  static String? _accessToken;

  static String? get token => _accessToken;
  static void setToken(String? t) => _accessToken = t;

  // 추후 로그인 기능 구현 시 해당 class를 활용해 토큰을 관리하면 좋을 듯 하다.
}