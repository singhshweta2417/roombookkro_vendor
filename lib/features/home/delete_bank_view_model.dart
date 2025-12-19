import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import 'package:room_book_kro_vendor/features/home/bank_list_view_model.dart';
import 'package:room_book_kro_vendor/features/home/repo/delete_bank_repo.dart';

class BankDeleteViewModel extends StateNotifier<BankDeleteState> {
  final BankDeleteRepository _getBankDeleteRepo;
  final Ref ref;

  BankDeleteViewModel(this._getBankDeleteRepo, this.ref)
    : super(const BankDeleteInitial());

  Future<void> bankDeleteApi(dynamic bankId, context) async {
    state = const BankDeleteLoading();

    try {
      final value = await _getBankDeleteRepo.bankDeleteApi(bankId);

      if (value["status"] == true) {
        Utils.show(value["message"].toString(), context);
        state = BankDeleteSuccess(message: value["message"].toString());
        await ref.read(getBankHistoryProvider.notifier).bankHistoryApi();
        Navigator.pop(context);
      } else {
        state = BankDeleteError(
          value["message"]?.toString() ?? "Delete failed",
        );
      }
    } catch (error) {
      state = BankDeleteError(error.toString());
    }
  }
}

abstract class BankDeleteState {
  const BankDeleteState();
}

class BankDeleteInitial extends BankDeleteState {
  const BankDeleteInitial();
}

class BankDeleteSuccess extends BankDeleteState {
  final String message;
  const BankDeleteSuccess({required this.message});
}

class BankDeleteError extends BankDeleteState {
  final String error;
  const BankDeleteError(this.error);
}

class BankDeleteLoading extends BankDeleteState {
  const BankDeleteLoading();
}

final getBankDeleteProvider =
    StateNotifierProvider<BankDeleteViewModel, BankDeleteState>((ref) {
      final getDepositRepo = ref.read(bankDeleteProvider);
      return BankDeleteViewModel(getDepositRepo, ref);
    });
