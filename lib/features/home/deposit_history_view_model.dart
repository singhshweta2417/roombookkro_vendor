import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/model/deposit_history_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/deposit_history_repo.dart';
import '../auth/data/user_view.dart';

class DepositHistoryViewModel extends StateNotifier<DepositHistoryState> {
  final DepositHistoryRepository _getDepositHistoryRepo;
  final Ref ref;

  DepositHistoryViewModel(this._getDepositHistoryRepo, this.ref)
    : super(DepositHistoryInitial());

  Future<void> depositHistoryApi() async {
    final userPref = ref.read(userViewModelProvider);
    final userId = await userPref.getUserId();
    state = DepositHistoryLoading();
    try {
      final value = await _getDepositHistoryRepo.depositHistoryApi(
        userId.toString(),
      );

      if (value.status == true) {
        state = DepositHistorySuccess(
          depositHistoryList: value,
          message: value.message.toString(),
        );
      }
    } catch (error) {
      state = DepositHistoryError(error.toString());
    }
  }
}

abstract class DepositHistoryState {
  const DepositHistoryState();
}

class DepositHistoryInitial extends DepositHistoryState {
  const DepositHistoryInitial();
}

class DepositHistorySuccess extends DepositHistoryState {
  final DepositHistoryModel depositHistoryList;
  final String message;

  const DepositHistorySuccess({
    required this.depositHistoryList,
    required this.message,
  });
}

class DepositHistoryError extends DepositHistoryState {
  final String error;

  const DepositHistoryError(this.error);
}

class DepositHistoryLoading extends DepositHistoryState {
  const DepositHistoryLoading();
}

final getDepositHistoryProvider =
    StateNotifierProvider<DepositHistoryViewModel, DepositHistoryState>((ref) {
      final getDepositRepo = ref.read(depositHistoryProvider);
      return DepositHistoryViewModel(getDepositRepo, ref);
    });
final selectedAmountProvider = StateProvider<Data?>((ref) => null);
