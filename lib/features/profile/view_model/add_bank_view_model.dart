import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import 'package:room_book_kro_vendor/features/profile/repo/add_bank_repo.dart';
import '../../auth/data/user_view.dart';

class AddBankViewModel extends StateNotifier<AddBankState> {
  final AddBankRepository _getAddBankRepo;
  final Ref ref;

  AddBankViewModel(this._getAddBankRepo, this.ref) : super(AddBankInitial());

  Future<void> addBankApi(
    dynamic accountHolderName,
    dynamic accountNumber,
    dynamic ifscCode,
    dynamic bankName,
    dynamic branchName,
    dynamic isDefault,
    dynamic context,
  ) async {
    state = AddBankLoading();
    final userPref = ref.read(userViewModelProvider);
    final userID = await userPref.getUserId();
    Map data = {
      "userId": userID.toString(),
      "accountHolderName": accountHolderName,
      "accountNumber": accountNumber,
      "ifscCode": ifscCode,
      "bankName": bankName,
      "branchName": branchName,
      "isDefault": isDefault,
    };
    try {
      final value = await _getAddBankRepo.addBankApi(data);
      if (value["status"] == true) {
        state = AddBankSuccess(message: 'Add Bank loaded successfully');
        Utils.show(value["message"].toString(), context);
        Navigator.pushNamed(context, AppRoutes.bankListScreen);
      }
    } catch (error) {
      state = AddBankError(error.toString());
    }
  }
}

abstract class AddBankState {
  const AddBankState();
}

class AddBankInitial extends AddBankState {
  const AddBankInitial();
}

class AddBankSuccess extends AddBankState {
  final String message;

  const AddBankSuccess({required this.message});
}

class AddBankError extends AddBankState {
  final String error;

  const AddBankError(this.error);
}

class AddBankLoading extends AddBankState {
  const AddBankLoading();
}

// Use the renamed repository provider
final addBankProvider = StateNotifierProvider<AddBankViewModel, AddBankState>((
  ref,
) {
  final getAddBankRepo = ref.read(addBankRepoProvider);
  return AddBankViewModel(getAddBankRepo, ref);
});
