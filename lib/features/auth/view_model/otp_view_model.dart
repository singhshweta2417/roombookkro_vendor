import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../../../core/utils/utils.dart';
import '../repo/otp_repo.dart';

class OtpViewModel extends StateNotifier<OtpState> {
  final OtpRepository _otpRepo;
  final Ref ref;

  OtpViewModel(this._otpRepo, this.ref) : super(const OtpInitial());

  Future<void> sentOtpApi(context, String? phone) async {
    state = const OtpLoading();
    final data = {"mobile_no": phone};
    try {
      final response = await _otpRepo.sentOtpApi(data);
      if (response["status"] == "success") {
        state = OtpSuccess(message: response["message"] ?? 'Success');
        Utils.show(response["message"], context);
        Navigator.pushReplacementNamed(
          ref.read(navigatorKeyProvider).currentContext!,
          AppRoutes.oTPFields,
          arguments: {"phone": phone},
        );
      } else {
        state = OtpError(response["message"] ?? 'Something went wrong');
        Utils.show(response["message"], context);
        Navigator.pushReplacementNamed(
          ref.read(navigatorKeyProvider).currentContext!,
          AppRoutes.registerScreen,
          arguments: {"phone": phone},
        );
      }
    } catch (e) {
      state = OtpError('Exception: ${e.toString()}');
    }
  }

  Future<dynamic> verifyOtpApi(
    BuildContext context,
    dynamic phoneNumber,
    dynamic myControllers,
  ) async {
    Map data = {"mobile_no": phoneNumber, "otp": myControllers};
    print(data);
    print("sdkvbshj");
    try {
      final response = await _otpRepo.verifyOtpApi(data);
      if (response["status"] == "success") {
        print("sdkvjbdjfvb");
        state = OtpSuccess(message: response["message"] ?? 'Success');
        Utils.show(response["message"], context);
      } else {
        state = OtpError(response["message"] ?? 'Something went wrong');
        Utils.show(response["message"], context);
      }
      return response;
    } catch (e) {
      state = OtpError('Exception: ${e.toString()}');
      return {"status": "error", "message": e.toString()};
    }
  }
}

abstract class OtpState {
  final bool isLoading;
  const OtpState({this.isLoading = false});
}

class OtpInitial extends OtpState {
  const OtpInitial() : super(isLoading: false);
}

class OtpLoading extends OtpState {
  const OtpLoading() : super(isLoading: true);
}

class OtpSuccess extends OtpState {
  final String message;

  const OtpSuccess({required this.message}) : super(isLoading: false);
}

class OtpError extends OtpState {
  final String error;
  const OtpError(this.error) : super(isLoading: false);
}

/// --------------------
/// Otp Provider
/// --------------------
final otpRepoProvider = StateNotifierProvider<OtpViewModel, OtpState>((ref) {
  final otpRepo = ref.read(otpProvider);
  return OtpViewModel(otpRepo, ref);
});
