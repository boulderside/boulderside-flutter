import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/core/user/data/services/user_block_service.dart';
import 'package:boulderside_flutter/src/core/user/models/blocked_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockedUsersStore extends StateNotifier<BlockedUsersState> {
  BlockedUsersStore(this._service) : super(const BlockedUsersState());

  final UserBlockService _service;

  Future<void> loadBlockedUsers() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final users = await _service.fetchBlockedUsers();
      state = state.copyWith(
        blockedUsers: users,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '차단한 사용자를 불러오지 못했습니다.',
        hasLoaded: true,
      );
    }
  }

  Future<void> ensureLoaded() async {
    if (state.hasLoaded || state.isLoading) return;
    await loadBlockedUsers();
  }

  Future<bool> blockUser(int targetUserId) async {
    try {
      await _service.blockUser(targetUserId);
      await loadBlockedUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(int blockedUserId) async {
    _setProcessing(blockedUserId, true);
    try {
      await _service.unblockUser(blockedUserId);
      state = state.copyWith(
        blockedUsers: state.blockedUsers
            .where((user) => user.id != blockedUserId)
            .toList(),
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _setProcessing(blockedUserId, false);
    }
  }

  void _setProcessing(int userId, bool isProcessing) {
    final next = Set<int>.from(state.processingUserIds);
    if (isProcessing) {
      next.add(userId);
    } else {
      next.remove(userId);
    }
    state = state.copyWith(processingUserIds: next);
  }
}

const _sentinel = Object();

class BlockedUsersState {
  const BlockedUsersState({
    this.blockedUsers = const <BlockedUser>[],
    this.isLoading = false,
    this.errorMessage,
    this.processingUserIds = const <int>{},
    this.hasLoaded = false,
  });

  final List<BlockedUser> blockedUsers;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> processingUserIds;
  final bool hasLoaded;

  bool isBlocked(int userId) {
    return blockedUsers.any((user) => user.id == userId);
  }

  BlockedUsersState copyWith({
    List<BlockedUser>? blockedUsers,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Set<int>? processingUserIds,
    bool? hasLoaded,
  }) {
    return BlockedUsersState(
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      processingUserIds: processingUserIds ?? this.processingUserIds,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

final blockedUsersStoreProvider =
    StateNotifierProvider<BlockedUsersStore, BlockedUsersState>((ref) {
      return BlockedUsersStore(di<UserBlockService>());
    });
