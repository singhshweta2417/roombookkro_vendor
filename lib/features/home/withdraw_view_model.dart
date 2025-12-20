import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import 'package:room_book_kro_vendor/features/auth/data/user_view.dart';
import 'package:room_book_kro_vendor/features/home/bank_list_view_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/withdraw_repo.dart';

class WithdrawViewModel extends StateNotifier<WithdrawState> {
  final WithdrawRepository _getWithdrawRepo;
  final Ref ref;

  WithdrawViewModel(this._getWithdrawRepo, this.ref) : super(WithdrawInitial());

  Future<void> withdrawApi({
    required String bankId,
    required String amount,
    required BuildContext context,
  }) async
  {
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();
    state = WithdrawLoading();

    Map<String, dynamic> data = {
      "userId": userID.toString(),
      "amount": amount,
      "bankId": bankId,
    };
    try {
      final value = await _getWithdrawRepo.withdrawApi(data);
      if (value["status"] == true) {
        state = WithdrawSuccess(message: 'Withdraw loaded successfully');
        Utils.show(value["message"].toString(), context);
        ref.read(getBankHistoryProvider.notifier).bankHistoryApi();
      }
    } catch (error) {
      state = WithdrawError(error.toString());
    }
  }
}

abstract class WithdrawState {
  const WithdrawState();
}

class WithdrawInitial extends WithdrawState {
  const WithdrawInitial();
}

class WithdrawSuccess extends WithdrawState {
  final String message;

  const WithdrawSuccess({required this.message});
}

class WithdrawError extends WithdrawState {
  final String error;

  const WithdrawError(this.error);
}

class WithdrawLoading extends WithdrawState {
  const WithdrawLoading();
}

// Use the renamed repository provider
final withdrawViewModelProvider =
    StateNotifierProvider<WithdrawViewModel, WithdrawState>((ref) {
      final repo = ref.read(withdrawProvider);
      return WithdrawViewModel(repo, ref);
    });
