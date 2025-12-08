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

/// ---------------------------
/// Register ViewModel
/// ---------------------------
class RegisterViewModel extends StateNotifier<RegisterState> {
  final AuthRepository _authRepo;
  final Ref ref;

  RegisterViewModel(this._authRepo, this.ref) : super(const RegisterInitial());

  String extractMessage(dynamic msg) {
    try {
      final text = msg.toString();
      final index = text.indexOf("{");
      if (index != -1) {
        final jsonString = text.substring(index);
        final decoded = jsonDecode(jsonString);
        return decoded["message"].toString();
      }
      return text;
    } catch (_) {
      return msg.toString();
    }
  }

  /// ---------------------------
  /// SIGNUP API
  /// ---------------------------
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
      // save user data
      final userPref = ref.read(userViewModelProvider);
      await userPref.saveToken(response.loginToken ?? "");
      await userPref.saveUserId(response.user?.userId.toString() ?? "");
      await userPref.saveUserType(response.user?.userType ?? "");
      state = RegisterSuccess(
        message: response.message ?? "Success",
        userId: response.user?.userId.toString() ?? "",
        userType: response.user?.userType,
      );
      final navigatorKey = ref.read(navigatorKeyProvider);
      navigatorKey.currentState?.pushReplacementNamed(
        AppRoutes.bottomNavigationPage,
      );
      Utils.show(response.message.toString(), context);
    } on BadRequestException catch (e) {
      final msg = extractMessage(e.message);
      state = RegisterError(msg);
      Utils.show(msg, context);
      await ref
          .read(otpRepoProvider.notifier)
          .sentOtpApi(context, phone.toString());
    } on FetchDataException catch (e) {
      state = RegisterError("${e.message}");
      final errorMsg = extractMessage(e.message);
      Utils.show(errorMsg, context);
      print(errorMsg);
      print("sfdjcksj");
    } on UnauthorisedException catch (e) {
      final msg = extractMessage(e.message);
      state = RegisterError(msg);
      Utils.show(msg, context);
    } on ServerException catch (e) {
      final msg = extractMessage(e.message);
      state = RegisterError(msg);
      Utils.show(msg, context);
    } catch (e) {
      state = RegisterError("Unexpected error: $e");
      Utils.show(e.toString(), context);
    }
  }
}

/// ---------------------------
/// STATES
/// ---------------------------
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
  });
}

class RegisterError extends RegisterState {
  final String error;
  const RegisterError(this.error);
}

/// ---------------------------
/// PROVIDER
/// ---------------------------
final registerProvider =
    StateNotifierProvider<RegisterViewModel, RegisterState>((ref) {
      final repo = ref.read(authRepositoryProvider);
      return RegisterViewModel(repo, ref);
    });
