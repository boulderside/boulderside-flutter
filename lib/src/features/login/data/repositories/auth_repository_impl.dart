import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:boulderside_flutter/src/features/login/data/models/request/oauth_login_request.dart';
import 'package:boulderside_flutter/src/features/login/data/services/oauth_login_service.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/domain/value_objects/social_login_result.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._tokenStore,
    this._userStore,
    this._oauthLoginService,
  );

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final OAuthLoginService _oauthLoginService;

  @override
  Future<SocialLoginResult> loginWithKakao({
    required String identityToken,
  }) async {
    final request = OAuthLoginRequest(
      providerType: 'KAKAO',
      identityToken: identityToken,
    );

    final response = await _oauthLoginService.login(request);

    await _tokenStore.saveTokens(
      response.accessToken,
      response.refreshToken,
      true,
    );

    final user = User(
      email: 'kakao_${response.userId}@oauth',
      nickname: response.nickname,
      profileImageUrl: response.profileImageUrl,
    );
    await _userStore.saveUser(user);

    return SocialLoginResult(user: user, isNew: response.isNew);
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clearTokens();
    await _userStore.clearUser();
  }
}
