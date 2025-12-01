import 'package:flutter/foundation.dart';
import 'package:boulderside_flutter/src/core/user/models/user.dart';
import 'package:boulderside_flutter/src/core/user/models/me_response.dart';
import 'package:boulderside_flutter/src/core/api/api_client.dart';
import 'package:boulderside_flutter/src/core/api/token_store.dart';

class UserStore extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // 앱 시작 시 사용자 정보 복원
  Future<void> initializeUser() async {
    try {
      final token = await TokenStore.getAccessToken();
      if (token == null) {
        return; // 토큰이 없으면 아무것도 하지 않음
      }

      final response = await ApiClient.dio.get('/users/me');

      if (response.statusCode == 200) {
        final responseData = response.data['data'];
        final meResponse = MeResponse.fromJson(responseData);

        // MeResponse를 User로 변환
        _user = User(
          email: meResponse.email,
          nickname: meResponse.nickname,
          profileImageUrl: meResponse.profileImageUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      // 토큰이 유효하지 않거나 네트워크 오류 시 사용자 정보 삭제
      await clearUser();
    }
  }

  // 로그인 성공 시 사용자 정보 저장
  Future<void> saveUser(User user) async {
    _user = user;
    notifyListeners();
  }

  // 로그아웃 시 사용자 정보 삭제
  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }

  // 사용자 정보 업데이트 (프로필 수정 시)
  Future<void> updateUser(User updatedUser) async {
    await saveUser(updatedUser);
  }
}
