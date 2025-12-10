enum AuthProviderType {
  kakao('KAKAO'),
  naver('NAVER'),
  apple('APPLE'),
  google('GOOGLE');

  const AuthProviderType(this.serverValue);

  final String serverValue;

  String get emailPrefix => name;
}
