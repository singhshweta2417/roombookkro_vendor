import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/model/withdraw_history_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/withdraw_history_repo.dart';
import '../auth/data/user_view.dart';

class WithdrawHistoryViewModel extends StateNotifier<WithdrawHistoryState> {
  final WithdrawHistoryRepository _getWithdrawHistoryRepo;
  final Ref ref;

  WithdrawHistoryViewModel(this._getWithdrawHistoryRepo, this.ref)
    : super(WithdrawHistoryInitial());

  Future<void> withdrawHistoryApi() async {
    final userPref = ref.read(userViewModelProvider);
    final userId = await userPref.getUserId();
    state = WithdrawHistoryLoading();
    try {
      final value = await _getWithdrawHistoryRepo.withdrawHistoryApi(
        userId.toString(),
      );

      if (value.status == true) {
        state = WithdrawHistorySuccess(
          withdrawHistoryList: value,
          message: value.message.toString(),
        );
      }
    } catch (error) {
      state = WithdrawHistoryError(error.toString());
    }
  }
}

abstract class WithdrawHistoryState {
  const WithdrawHistoryState();
}

class WithdrawHistoryInitial extends WithdrawHistoryState {
  const WithdrawHistoryInitial();
}

class WithdrawHistorySuccess extends WithdrawHistoryState {
  final WithdrawHistoryModel withdrawHistoryList;
  final String message;

  const WithdrawHistorySuccess({
    required this.withdrawHistoryList,
    required this.message,
  });
}

class WithdrawHistoryError extends WithdrawHistoryState {
  final String error;

  const WithdrawHistoryError(this.error);
}

class WithdrawHistoryLoading extends WithdrawHistoryState {
  const WithdrawHistoryLoading();
}

final getWithdrawHistoryProvider =
    StateNotifierProvider<WithdrawHistoryViewModel, WithdrawHistoryState>((
      ref,
    ) {
      final getWithdrawRepo = ref.read(withdrawHistoryProvider);
      return WithdrawHistoryViewModel(getWithdrawRepo, ref);
    });
