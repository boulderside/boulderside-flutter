import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';
import 'package:boulderside_flutter/src/core/user/models/me_response.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStore extends StateNotifier<UserState> {
  UserStore(this._tokenStore) : super(const UserState());

  final TokenStore _tokenStore;

  User? get user => state.user;
  bool get isLoggedIn => state.isLoggedIn;

  // 앱 시작 시 사용자 정보 복원
  Future<void> initializeUser() async {
    try {
      final token = await _tokenStore.getAccessToken();
      if (token == null) {
        return;
      }

      final response = await ApiClient.dio.get('/users/me');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final meResponse = MeResponse.fromJson(responseData);

        state = state.copyWith(
          user: User(
            email: meResponse.email,
            nickname: meResponse.nickname,
            profileImageUrl: meResponse.profileImageUrl,
            marketingConsentAgreed: meResponse.marketingConsentAgreed,
          ),
        );
      }
    } catch (e) {
      await clearUser();
    }
  }

  // 로그인 성공 시 사용자 정보 저장
  Future<void> saveUser(User user) async {
    state = state.copyWith(user: user);
  }

  // 로그아웃 시 사용자 정보 삭제
  Future<void> clearUser() async {
    state = const UserState();
  }

  // 사용자 정보 업데이트 (프로필 수정 시)
  Future<void> updateUser(User updatedUser) async {
    await saveUser(updatedUser);
  }
}

const _sentinel = Object();

class UserState {
  const UserState({this.user});

  final User? user;

  bool get isLoggedIn => user != null;

  UserState copyWith({Object? user = _sentinel}) {
    return UserState(
      user: identical(user, _sentinel) ? this.user : user as User?,
    );
  }
}
