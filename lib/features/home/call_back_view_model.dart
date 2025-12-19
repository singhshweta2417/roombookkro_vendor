import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/features/auth/data/user_view.dart';
import 'package:room_book_kro_vendor/features/auth/model/profile_model.dart';
import 'package:room_book_kro_vendor/features/home/dialog_widget.dart';
import 'package:room_book_kro_vendor/features/profile/repo/profile_repo.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/utils/utils.dart';


class TopUpViewModel extends StateNotifier<AuthState> {
  final ProfileRepository _profileRepo;
  final Ref ref;

  TopUpViewModel(this._profileRepo, this.ref) : super(const AuthInitial());

  /// ---- Update Profile API ----
  Future<void> profileUpdateApi({
    String? walletBalance,
    context
  }) async {
    state = const AuthLoading();
    final data = {
      "walletBalance":walletBalance
    };
    try {
      final userPref = ref.read(userViewModelProvider);
      final userID = await userPref.getUserId();
      final response = await _profileRepo.profileUpdateApi(userID, data);
      if (response["status"] == 200) {
        state = ProfileSuccess(
          message: response["message"] ?? "Profile updated successfully",
        );
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => PaymentSuccessDialog(
              message: "You have successfully made a payment",
            ),
          );
        }
      } else {
        state = AuthError(response["message"] ?? "Something went wrong");
        Utils.show(response["message"].toString(), context);
      }
    } on BadRequestException catch (e) {
      state = AuthError("No Changes Detected");
      Utils.show("No Changes Detected", context);
    } catch (error) {
      state = AuthError(error.toString());
    }
  }

}

/// ---- Auth States ----
abstract class AuthState {
  final bool isLoading;
  const AuthState({this.isLoading = false});
}

class AuthInitial extends AuthState {
  const AuthInitial() : super(isLoading: false);
}

class ProfileSuccess extends AuthState {
  final String message;
  final Profile? profile;
  const ProfileSuccess({required this.message, this.profile})
      : super(isLoading: false);
}


class AuthError extends AuthState {
  final String error;
  const AuthError(this.error) : super(isLoading: false);
}

class AuthLoading extends AuthState {
  const AuthLoading() : super(isLoading: true);
}

/// ---- Provider ----
final topUpEWalletProvider = StateNotifierProvider<TopUpViewModel, AuthState>((ref) {
  final profileRepo = ref.read(profileUpdateProvider);
  return TopUpViewModel(profileRepo, ref);
});
