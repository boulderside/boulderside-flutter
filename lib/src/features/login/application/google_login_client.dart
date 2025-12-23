import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleLoginClient {
  Future<GoogleLoginResult> login();
}

class GoogleLoginClientImpl implements GoogleLoginClient {
  GoogleLoginClientImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _createGoogleSignIn() {
    // iOS Client ID (--dart-define으로 전달)
    const iosClientId = String.fromEnvironment('GOOGLE_CLIENT_ID_IOS');

    // Android/Web용 Server Client ID (--dart-define으로 전달)
    const serverClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

    // 실제 전달될 값 확인
    final finalClientId = iosClientId.isNotEmpty ? iosClientId : null;
    final finalServerClientId = serverClientId.isNotEmpty ? serverClientId : null;

    return GoogleSignIn(
      // iOS에서 사용할 Client ID
      clientId: finalClientId,
      // Android에서 ID Token을 받기 위한 Server Client ID (Web Client ID)
      serverClientId: finalServerClientId,
      scopes: ['email', 'profile'],
    );
  }

  @override
  Future<GoogleLoginResult> login() async {
    try {
      GoogleSignInAccount? account = _googleSignIn.currentUser;

      // 캐시된 계정이 있으면 로그아웃 (serverClientId 설정 반영을 위해)
      if (account != null) {
        await _googleSignIn.signOut();
        account = null;
      }

      account = await _googleSignIn.signIn();

      if (account == null) {
        return GoogleLoginResult.cancelled();
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        return GoogleLoginResult.failure('Google ID 토큰을 가져올 수 없습니다.');
      }

      return GoogleLoginResult.success(
        idToken: idToken,
        accessToken: accessToken,
        userId: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (error) {
      return GoogleLoginResult.failure(error.toString());
    }
  }
}

class GoogleLoginResult {
  const GoogleLoginResult._({
    this.idToken,
    this.accessToken,
    this.email,
    this.userId,
    this.displayName,
    this.photoUrl,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory GoogleLoginResult.success({
    required String idToken,
    String? accessToken,
    required String userId,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return GoogleLoginResult._(
      idToken: idToken,
      accessToken: accessToken,
      userId: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  factory GoogleLoginResult.failure(String message) {
    return GoogleLoginResult._(errorMessage: message);
  }

  factory GoogleLoginResult.cancelled() {
    return const GoogleLoginResult._(isCancelled: true);
  }

  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? userId;
  final String? displayName;
  final String? photoUrl;
  final String? errorMessage;
  final bool isCancelled;

  bool get isSuccess =>
      idToken != null && errorMessage == null && !isCancelled;
}
