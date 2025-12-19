import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import 'package:room_book_kro_vendor/features/home/repo/bank_update_repo.dart';

class BankUpdateViewModel extends StateNotifier<UpdateBankState> {
  final BankUpdateRepository _getUpdateBankRepo;
  final Ref ref;

  BankUpdateViewModel(this._getUpdateBankRepo, this.ref)
    : super(UpdateBankInitial());

  Future<void> updateBankApi({
    required String bankId,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    required String branchName,
    required BuildContext context,
  }) async {
    state = UpdateBankLoading();
    Map<String, dynamic> data  = {
      "accountHolderName": accountHolderName,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "bankName": bankName,
      "branchName": branchName,
    };
    try {
      final value = await _getUpdateBankRepo.bankUpdateApi(bankId, data);
      if (value["status"] == true) {
        state = UpdateBankSuccess(message: 'Update Bank loaded successfully');
        Utils.show(value["message"].toString(), context);
      }
    } catch (error) {
      state = UpdateBankError(error.toString());
    }
  }
}

abstract class UpdateBankState {
  const UpdateBankState();
}

class UpdateBankInitial extends UpdateBankState {
  const UpdateBankInitial();
}

class UpdateBankSuccess extends UpdateBankState {
  final String message;

  const UpdateBankSuccess({required this.message});
}

class UpdateBankError extends UpdateBankState {
  final String error;

  const UpdateBankError(this.error);
}

class UpdateBankLoading extends UpdateBankState {
  const UpdateBankLoading();
}

// Use the renamed repository provider
final updateBankViewModelProvider =
StateNotifierProvider<BankUpdateViewModel, UpdateBankState>((ref) {
  final repo = ref.read(bankUpdateProvider);
  return BankUpdateViewModel(repo, ref);
});

