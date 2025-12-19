import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import '../../../core/google_services/firebase_notifications.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/routes/navigator_key_provider.dart';
import '../data/user_view.dart';
import '../repo/auth_repo.dart';
import 'otp_view_model.dart';

/// --------------------
/// Register ViewModel
/// --------------------
class RegisterViewModel extends StateNotifier<RegisterState> {
  final AuthRepository _authRepo;
  final Ref ref;

  RegisterViewModel(this._authRepo, this.ref) : super(const RegisterInitial());

  String extractMessage(dynamic msg) {
    try {
      if (msg is String && msg.contains("{")) {
        final decoded = jsonDecode(msg);
        return decoded["message"].toString();
      }
      return msg.toString();
    } catch (_) {
      return msg.toString();
    }
  }

  Future<void> signUpApi({
    required String name,
    required String mail,
    required String phone,
    required String date,
    required String adharNumber,
    required String panNumber,
    required String adharFront,
    required String adharBack,
    required String panImage,
    required context,
  }) async {
    state = const RegisterLoading();

    final fcmToken = await ref
        .read(notificationServiceProvider)
        .getDeviceToken();

    final data = {
      "action": "signup",
      "name": name,
      "email": mail,
      "user_type": "1",
      "phone": phone,
      "DOB": date,
      "fcmToken": fcmToken,
      "adharNumber": adharNumber,
      "panNumber": panNumber,
      "adharFront": adharFront,
      "adharBack": adharBack,
      "panImage": panImage,
    };

    try {
      final response = await _authRepo.signUpApi(data);

      // Update state to success
      state = RegisterSuccess(
        message: response.message ?? "Success",
        userId: response.user?.userId.toString() ?? "",
        userType: response.user?.userType,
      );

      // Save user data
      final userPref = ref.read(userViewModelProvider);
      await userPref.saveToken(response.loginToken ?? "");
      await userPref.saveUserId(response.user?.userId.toString() ?? "");
      await userPref.saveUserType(response.user?.userType ?? "");

      // Show success message
      final successMsg = extractMessage(response.message);
      Utils.show(successMsg, context);

      // Navigate after delay (same as login)
      final navigatorKey = ref.read(navigatorKeyProvider);
      Future.delayed(const Duration(milliseconds: 300), () {
        final currentState = navigatorKey.currentState;
        if (currentState != null) {
          currentState.pushReplacementNamed(
            AppRoutes.bottomNavigationPage,
          );
        }
      });

    } on BadRequestException catch (e) {
      state = RegisterError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);

      // Send OTP on bad request
      await ref
          .read(otpRepoProvider.notifier)
          .sentOtpApi(context, phone.toString());

    } on FetchDataException catch (e) {
      state = RegisterError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);

    } on UnauthorisedException catch (e) {
      state = RegisterError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);

    } on ServerException catch (e) {
      state = RegisterError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);

    } catch (e) {
      state = RegisterError("Unexpected error: $e");
      Utils.show(e.toString(), context);
    }
  }
}

/// --------------------
/// Register States
/// --------------------
abstract class RegisterState {
  final bool isLoading;
  const RegisterState({this.isLoading = false});
}

class RegisterInitial extends RegisterState {
  const RegisterInitial() : super(isLoading: false);
}

class RegisterLoading extends RegisterState {
  const RegisterLoading() : super(isLoading: true);
}

class RegisterSuccess extends RegisterState {
  final String message;
  final String userId;
  final String? userType;

  const RegisterSuccess({
    required this.message,
    required this.userId,
    this.userType,
  }) : super(isLoading: false);
}

class RegisterError extends RegisterState {
  final String error;
  const RegisterError(this.error) : super(isLoading: false);
}

/// --------------------
/// Register Provider
/// --------------------
final registerProvider =
StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterViewModel(repo, ref);
});