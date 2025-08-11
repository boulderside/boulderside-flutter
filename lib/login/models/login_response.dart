class LoginResponse {
  final String email;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  // API 요청 시 응답 데이터인 JSON을 파싱하는 코드
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      email: json['email'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
