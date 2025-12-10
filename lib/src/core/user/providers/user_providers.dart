import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/user/data/services/nickname_service.dart';
import 'package:boulderside_flutter/src/core/user/stores/user_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStoreProvider = StateNotifierProvider<UserStore, UserState>((ref) {
  return di<UserStore>();
});

final nicknameServiceProvider = Provider<NicknameService>((ref) {
  return di<NicknameService>();
});
