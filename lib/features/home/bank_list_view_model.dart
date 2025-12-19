import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/model/bank_detail_list_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/bank_list_repo.dart';
import '../auth/data/user_view.dart';

class BankHistoryViewModel extends StateNotifier<BankHistoryState> {
  final BankHistoryRepository _getBankHistoryRepo;
  final Ref ref;

  BankHistoryViewModel(this._getBankHistoryRepo, this.ref)
    : super(BankHistoryInitial());

  Future<void> bankHistoryApi() async {
    final userPref = ref.read(userViewModelProvider);
    final userId = await userPref.getUserId();
    state = BankHistoryLoading();
    try {
      final value = await _getBankHistoryRepo.bankHistoryApi(userId.toString());

      if (value.status == true) {
        state = BankHistorySuccess(
          bankHistoryList: value,
          message: value.message.toString(),
        );
      }
    } catch (error) {
      state = BankHistoryError(error.toString());
    }
  }
}

abstract class BankHistoryState {
  const BankHistoryState();
}

class BankHistoryInitial extends BankHistoryState {
  const BankHistoryInitial();
}

class BankHistorySuccess extends BankHistoryState {
  final BankDetailsListModel bankHistoryList;
  final String message;

  const BankHistorySuccess({
    required this.bankHistoryList,
    required this.message,
  });
}

class BankHistoryError extends BankHistoryState {
  final String error;

  const BankHistoryError(this.error);
}

class BankHistoryLoading extends BankHistoryState {
  const BankHistoryLoading();
}

final getBankHistoryProvider =
    StateNotifierProvider<BankHistoryViewModel, BankHistoryState>((ref) {
      final getDepositRepo = ref.read(bankHistoryProvider);
      return BankHistoryViewModel(getDepositRepo, ref);
    });
