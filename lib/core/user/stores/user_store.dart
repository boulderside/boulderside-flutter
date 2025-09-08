import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserStore extends ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  // 앱 시작 시 사용자 정보 복원
  Future<void> initializeUser() async {
    // API 만든 후 붙이기
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
