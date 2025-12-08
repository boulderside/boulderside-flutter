import 'package:boulderside_flutter/src/app/di/dependencies.dart';
import 'package:boulderside_flutter/src/features/login/data/services/change_password_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordStore extends StateNotifier<ChangePasswordState> {
  ChangePasswordStore(this._changePasswordService)
    : super(const ChangePasswordState());

  final ChangePasswordService _changePasswordService;

  Future<void> changePassword(String phoneNumber, String newPassword) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isPasswordChanged: false,
    );

    try {
      await _changePasswordService.changePassword(phoneNumber, newPassword);
      state = state.copyWith(
        isLoading: false,
        isPasswordChanged: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isPasswordChanged: false,
      );
    }
  }

  void reset() {
    state = const ChangePasswordState();
  }
}

const _sentinel = Object();

class ChangePasswordState {
  const ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordChanged = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordChanged;

  ChangePasswordState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    bool? isPasswordChanged,
  }) {
    return ChangePasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isPasswordChanged: isPasswordChanged ?? this.isPasswordChanged,
    );
  }
}

final changePasswordStoreProvider =
    StateNotifierProvider<ChangePasswordStore, ChangePasswordState>((ref) {
      final service = di<ChangePasswordService>();
      return ChangePasswordStore(service);
    });
