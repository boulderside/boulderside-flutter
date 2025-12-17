import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boulderside_flutter/src/features/login/domain/repositories/auth_repository.dart';
import 'package:boulderside_flutter/src/features/login/providers/login_providers.dart';

class WithdrawalViewModel extends StateNotifier<AsyncValue<void>> {
  WithdrawalViewModel(this._authRepository)
    : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;

  Future<bool> withdraw(String? reason) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _authRepository.withdraw(reason: reason),
    );
    return !state.hasError;
  }
}

final withdrawalViewModelProvider =
    StateNotifierProvider.autoDispose<WithdrawalViewModel, AsyncValue<void>>((
      ref,
    ) {
      return WithdrawalViewModel(ref.watch(authRepositoryProvider));
    });
